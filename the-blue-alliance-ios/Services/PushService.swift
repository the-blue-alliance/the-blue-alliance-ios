import FirebaseMessaging
import Foundation
import MyTBAKit
import TBAAuth
import TBAUtils
import UserNotifications
import UIKit

protocol RemoteNotificationRegistering: AnyObject {
    func registerForRemoteNotifications(completion: ((Error?) -> Void)?)
}

protocol PushServiceProtocol: AnyObject {
    func registerForRemoteNotifications(_ completion: ((Error?) -> Void)?)
    @discardableResult func requestAuthorizationForNotifications() async throws -> Bool
    /// Invalidates this device's FCM token so pushes to it fail at Firebase.
    /// Needs no TBA auth, which is what makes sign-out safe to finish offline.
    func deletePushToken() async throws
}

// PushService handles registering push notification tokens with TBA and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject, PushServiceProtocol {

    private let reporter: any Reporter
    private let authService: any AuthServiceProtocol
    private let myTBA: any MyTBAProtocol
    private let registrar: any RemoteNotificationRegistering
    weak var router: (any PushNotificationRouting)?

    private var registerTask: Task<Void, Never>?

    init(
        reporter: any Reporter,
        authService: any AuthServiceProtocol,
        myTBA: any MyTBAProtocol,
        registrar: any RemoteNotificationRegistering
    ) {
        self.reporter = reporter
        self.authService = authService
        self.myTBA = myTBA
        self.registrar = registrar

        super.init()
    }

    // Registering needs both a signed-in user and an FCM token, and either can
    // arrive first, so both events land here. Restarting replaces any attempt
    // already in flight, which is what a refreshed token needs anyway. Retries
    // once a minute until the server accepts it.
    fileprivate func registerPushToken() {
        registerTask?.cancel()
        guard authService.isSignedIn else {
            return
        }
        registerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                do {
                    _ = try await myTBA.register()
                    return
                } catch {
                    guard !Task.isCancelled else { return }
                    reporter.record(error)
                }
                try? await Task.sleep(for: .seconds(60))
            }
        }
    }

    func registerForRemoteNotifications(_ completion: ((Error?) -> Void)?) {
        registrar.registerForRemoteNotifications(completion: completion)
    }

}

extension PushService {

    @discardableResult
    func requestAuthorizationForNotifications() async throws -> Bool {
        return try await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        )
    }

    func deletePushToken() async throws {
        // No token means this device was never registered, so there's nothing
        // to stop - and nothing for Firebase to delete.
        guard Messaging.messaging().fcmToken != nil else {
            return
        }
        try await Messaging.messaging().deleteToken()
    }

}

extension PushService: AuthStateObserving {

    func authStateChanged(isSignedIn: Bool) {
        if isSignedIn {
            registerPushToken()
        } else {
            registerTask?.cancel()
        }
    }
}

extension PushService: MessagingDelegate {

    // Firebase always delivers this on the main thread (it hops in
    // -[FIRMessaging notifyDelegateOfFCMTokenAvailability]), which is why a
    // main-actor method can witness this nonisolated requirement directly.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        registerPushToken()
    }

}

extension PushService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let payload = PushNotificationPayload.parse(notification.request.content.userInfo)
        if case .silentRefresh = payload {
            completionHandler([])
            return
        }
        completionHandler([.banner, .list, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let payload = PushNotificationPayload.parse(userInfo) else {
            completionHandler()
            return
        }
        Task { @MainActor [weak self] in
            self?.router?.handleTap(payload)
            completionHandler()
        }
    }

}
