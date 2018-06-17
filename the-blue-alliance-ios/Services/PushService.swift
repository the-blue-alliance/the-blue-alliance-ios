import Crashlytics
import FirebaseMessaging
import Foundation
import UserNotifications

// PushService handles registering push notification tokens with TBA and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject {

    private enum DefaultKeys: String {
        case pendingRegisterPushToken = "kPendingPushToken"
        case pendingUnregisterPushTokens = "kPendingUnregisterPushTokens"
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

    private var pendingUnregisterPushTokens: Set<String> {
        get {
            let arr = userDefaults.array(forKey: DefaultKeys.pendingUnregisterPushTokens.rawValue) as? [String] ?? []
            return Set(arr)
        }
        set {
            let arr = Array(newValue)
            userDefaults.set(arr, forKey: DefaultKeys.pendingUnregisterPushTokens.rawValue)
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
            _ = myTBA.register(token) { (error) in
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

    // Unregister is unused right now because myTBA needs to be auth'd to unregister but we unregister after a log out..
    /*
    static func unregisterPushToken(_ token: String) {
        if MyTBA.shared.authentication == nil {
            // Not authenticated to MyTBA - save token for unregister once we're auth'd
            pendingUnregisterPushTokens.insert(token)
        } else {
            _ = MyTBA.shared.unregister(token, completion: { (error) in
                if let error = error {
                    Crashlytics.sharedInstance().recordError(error)
                    pendingUnregisterPushTokens.insert(token)
                } else {
                    pendingUnregisterPushTokens.remove(token)
                }
            })
        }
    }
    
    // To be used by a background timer
    private static func unregisterPendingPushTokens() {
        for token in pendingUnregisterPushTokens {
            unregisterPushToken(token)
        }
    }
    */

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
        // TODO: By the nature of unregister being hooked up to unauth'd... won't this ALWAYS fail?
        // We should fix this, but probably fix this server-side, where unregister isn't an auth'd endpoint?
        // Or maybe we can unauth if we pass the previous registration token or something?
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/175
        /*
        if let currentPushToken = Messaging.messaging().fcmToken {
            PushService.unregisterPushToken(currentPushToken)
        }
        */
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
        // Retry push notification register/unregister once a minute until success
        return 1 * 60
    }

    func retry() {
        registerPendingPushToken()
    }

}
