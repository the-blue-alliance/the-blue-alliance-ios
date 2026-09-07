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
    internal var retryService: RetryService
    private let registrar: any RemoteNotificationRegistering
    weak var router: (any PushNotificationRouting)?

    private var registerTask: Task<Void, Never>?

    init(
        reporter: any Reporter,
        authService: any AuthServiceProtocol,
        myTBA: any MyTBAProtocol,
        retryService: RetryService,
        registrar: any RemoteNotificationRegistering
    ) {
        self.reporter = reporter
        self.authService = authService
        self.myTBA = myTBA
        self.retryService = retryService
        self.registrar = registrar

        super.init()
    }

    // Reads auth state, which lives on the main actor. The two callers that
    // arrive off it (Firebase's delegate queue, the retry timer) hop first.
    @MainActor
    fileprivate func registerPushToken() {
        if !authService.isSignedIn {
            // Not authenticated to myTBA - we'll try again when we're auth'd
            return
        }
        guard registerTask == nil else {
            // Hack-y fix for register being called twice during app startup -
            // Once from AuthStateObserving.authStateChanged and once from
            // MessagingDelegate.didReceiveRegistrationToken
            // We should look to fix this properly some other time
            return
        }
        registerTask = Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await self.myTBA.register()
                self.unregisterRetryable()
            } catch {
                self.reporter.record(error)
                if !self.retryService.isRetryRegistered {
                    await MainActor.run { self.registerRetryable() }
                }
            }
            self.registerTask = nil
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
        } else if retryService.isRetryRegistered {
            unregisterRetryable()
        }
    }
}

extension PushService: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "N/A")")
        Task { @MainActor in registerPushToken() }
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

extension PushService: Retryable {

    var retryInterval: TimeInterval {
        // Retry push notification register once a minute until success
        return 1 * 60
    }

    func retry() {
        Task { @MainActor in registerPushToken() }
    }

}
