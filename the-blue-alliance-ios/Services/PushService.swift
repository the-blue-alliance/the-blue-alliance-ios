import FirebaseMessaging
import Foundation
import MyTBAKit
import TBAUtils
import UserNotifications
import UIKit

// PushService handles registering push notification tokens with TBA and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject {

    private let errorRecorder: ErrorRecorder
    private var myTBA: MyTBA
    internal var retryService: RetryService

    private let operationQueue = OperationQueue()

    init(errorRecorder: ErrorRecorder, myTBA: MyTBA, retryService: RetryService) {
        self.errorRecorder = errorRecorder
        self.myTBA = myTBA
        self.retryService = retryService

        super.init()
    }

    fileprivate func registerPushToken() {
        if !myTBA.isAuthenticated {
            // Not authenticated to myTBA - we'll try again when we're auth'd
            return
        }
        guard operationQueue.operationCount == 0 else {
            // Hack-y fix for register being called twice during app startup -
            // Once from MyTBAAuthenticationObservable.authenticated and once from
            // MessagingDelegate.didReceiveRegistrationToken
            // We should look to fix this properly some other time
            return
        }
        let registerOperation = myTBA.register { (_, error) in
            if let error = error {
                self.errorRecorder.record(error)
                if !self.retryService.isRetryRegistered {
                    DispatchQueue.main.async {
                        self.registerRetryable()
                    }
                }
            } else {
                self.unregisterRetryable()
            }
        }
        guard let op = registerOperation else { return }
        operationQueue.addOperation(op)
    }

    static func requestAuthorizationForNotifications(_ completion: ((Bool, Error?) -> Void)?) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
            completion?(granted, error)
        }
    }

    static func registerForRemoteNotifications(_ completion: ((Error?) -> ())?) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get application delegate in PushService registerForRemoteNotifications")
        }

        delegate.registerForRemoteNotificationsCompletion = completion
        UIApplication.shared.registerForRemoteNotifications()
    }

}

extension PushService: MyTBAAuthenticationObservable {

    func authenticated() {
        registerPushToken()
    }

    func unauthenticated() {
        if self.retryService.isRetryRegistered {
            self.unregisterRetryable()
        }
    }
}

extension PushService: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "N/A")")
        registerPushToken()
    }

}

extension PushService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Called when we're in the foreground and we recieve a notification
        // Show all notifications in the foreground
        print("Foreground push notification")
        print(notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called when we click a notification
        // TODO: Push to view controllers from notification
        let userInfo = response.notification.request.content.userInfo
        print("Push notification")
        print(userInfo)

        // Handle being launched from a push notification
        completionHandler()
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
