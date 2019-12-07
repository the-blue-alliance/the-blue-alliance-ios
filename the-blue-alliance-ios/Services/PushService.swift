import Crashlytics
import FirebaseMessaging
import Foundation
import MyTBAKit
import UserNotifications

// PushService handles registering push notification tokens with TBA and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject {

    private var myTBA: MyTBA
    internal var retryService: RetryService

    private let operationQueue = OperationQueue()

    init(myTBA: MyTBA, retryService: RetryService) {
        self.myTBA = myTBA
        self.retryService = retryService

        super.init()
    }

    fileprivate func registerPushToken() {
        if !myTBA.isAuthenticated {
            // Not authenticated to myTBA - we'll try again when we're auth'd
            return
        }
        let registerOperation = myTBA.register { (_, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
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

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        registerPushToken()
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("FCM Remote Data")
        print(remoteMessage.appData)
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
