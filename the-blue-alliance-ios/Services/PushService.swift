import Crashlytics
import FirebaseMessaging
import Foundation
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

    private var userDefaults: UserDefaults
    private var myTBA: MyTBA
    internal var retryService: RetryService

    init(userDefaults: UserDefaults, myTBA: MyTBA, retryService: RetryService) {
        self.userDefaults = userDefaults
        self.myTBA = myTBA
        self.retryService = retryService

        super.init()
    }

    fileprivate func registerPushToken(_ token: String) {
        if !myTBA.isAuthenticated {
            // Not authenticated to MyTBA - save token for registration once we're auth'd
            pendingRegisterPushToken = token
        } else {
            myTBA.register(token) { (error) in
                if let error = error {
                    Crashlytics.sharedInstance().recordError(error)
                    DispatchQueue.main.async {
                        self.registerRetryable()
                    }
                } else {
                    self.unregisterRetryable()
                }
                // Either save or remove our pending push token as necessary
                self.pendingRegisterPushToken = (error != nil ? token : nil)
            }
        }
    }

    private func registerPendingPushToken() {
        guard let pendingRegisterPushToken = pendingRegisterPushToken else {
            return
        }
        registerPushToken(pendingRegisterPushToken)
    }

    static func requestAuthorizationForNotifications(_ completion: ((Error?) -> Void)?) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
            if let completion = completion {
                completion(error)
            }
        }
    }

}

extension PushService: MyTBAAuthenticationObservable {

    func authenticated() {
        registerPendingPushToken()
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
        print(remoteMessage.appData)
    }

}

extension PushService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print full message.
        print("Will present")
        print(userInfo)

        // Handle notification information in foreground
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print full message.
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
