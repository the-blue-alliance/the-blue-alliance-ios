import FirebaseMessaging
import Foundation
import MyTBAKit
import TBAUtils
import UserNotifications
import UIKit

protocol RemoteNotificationRegistering: AnyObject {
    func registerForRemoteNotifications(completion: ((Error?) -> Void)?)
}

protocol PushServiceProtocol: AnyObject {
    func registerForRemoteNotifications(_ completion: ((Error?) -> Void)?)
}

// PushService handles registering push notification tokens with TBA and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject, PushServiceProtocol {

    private let errorRecorder: ErrorRecorder
    private var myTBA: any MyTBAProtocol
    internal var retryService: RetryService
    private let registrar: any RemoteNotificationRegistering

    private var registerTask: Task<Void, Never>?
    private var authStateTask: Task<Void, Never>?

    init(
        errorRecorder: ErrorRecorder,
        myTBA: any MyTBAProtocol,
        retryService: RetryService,
        registrar: any RemoteNotificationRegistering
    ) {
        self.errorRecorder = errorRecorder
        self.myTBA = myTBA
        self.retryService = retryService
        self.registrar = registrar

        super.init()

        authStateTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await self.myTBA.authStateChanges()
            for await isAuthenticated in stream {
                self.applyAuthState(isAuthenticated: isAuthenticated)
            }
        }
    }

    deinit {
        authStateTask?.cancel()
    }

    private func applyAuthState(isAuthenticated: Bool) {
        if isAuthenticated {
            registerPushToken()
        } else if retryService.isRetryRegistered {
            unregisterRetryable()
        }
    }

    fileprivate func registerPushToken() {
        if !myTBA.isAuthenticated {
            // Not authenticated to myTBA - we'll try again when we're auth'd
            return
        }
        guard registerTask == nil else {
            // Hack-y guard against register being called twice during app startup —
            // once from the auth-state stream and once from MessagingDelegate's
            // `didReceiveRegistrationToken`. Should be untangled some day.
            return
        }
        registerTask = Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await self.myTBA.register()
                self.unregisterRetryable()
            } catch {
                self.errorRecorder.record(error)
                if !self.retryService.isRetryRegistered {
                    await MainActor.run { self.registerRetryable() }
                }
            }
            self.registerTask = nil
        }
    }

    static func requestAuthorizationForNotifications(_ completion: ((Bool, Error?) -> Void)?) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {
            (granted, error) in
            completion?(granted, error)
        }
    }

    func registerForRemoteNotifications(_ completion: ((Error?) -> Void)?) {
        registrar.registerForRemoteNotifications(completion: completion)
    }

}

extension PushService: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "N/A")")
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
        // Show all notifications in the foreground.
        completionHandler([.banner, .list, .badge, .sound])
    }

}

extension PushService: Retryable {

    var retryInterval: TimeInterval {
        // Retry push notification register once a minute until success
        return 1 * 60
    }

    func retry() {
        registerPushToken()
    }

}
