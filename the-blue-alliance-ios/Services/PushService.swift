import Crashlytics
import FirebaseMessaging
import Foundation
import MyTBAKit
import UserNotifications

// PushService handles registering push notification tokens with TBA and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject {

    private enum DefaultKeys: String {
        case pendingRegisterPushToken = "kPendingPushToken"
    }

    private var pendingRegisterPushToken: String? {
        get {
            return userDefaults.string(forKey: DefaultKeys.pendingRegisterPushToken.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: DefaultKeys.pendingRegisterPushToken.rawValue)
            userDefaults.synchronize()
        }
    }

    private var messaging: Messaging
    private var myTBA: MyTBA
    internal var retryService: RetryService
    private var userDefaults: UserDefaults

    private let operationQueue = OperationQueue()

    init(messaging: Messaging, myTBA: MyTBA, retryService: RetryService, userDefaults: UserDefaults) {
        self.messaging = messaging
        self.myTBA = myTBA
        self.retryService = retryService
        self.userDefaults = userDefaults

        super.init()
    }

    fileprivate func registerPushToken(_ token: String) {
        if !myTBA.isAuthenticated {
            // Not authenticated to myTBA - save token for registration once we're auth'd
            pendingRegisterPushToken = token
        } else {
            let op = myTBA.register(token) { (_, error) in
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
                // Either save or remove our pending push token as necessary
                self.pendingRegisterPushToken = (error != nil ? token : nil)
            }
            if let op = op {
                operationQueue.addOperation(op)
            }
        }
    }

    func registerFCMToken() {
        guard let fcmToken = messaging.fcmToken else {
            return
        }
        registerPushToken(fcmToken)
    }

    private func registerPendingPushToken() {
        guard let pendingRegisterPushToken = pendingRegisterPushToken else {
            return
        }
        registerPushToken(pendingRegisterPushToken)
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
        registerFCMToken()
    }

    func unauthenticated() {
        // unregister isn't asynchronous, so we don't subscribe to it
    }
}

extension PushService: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        registerPushToken(fcmToken)
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
        registerPendingPushToken()
    }

}
