import Foundation
import Firebase
import UserNotifications
import Crashlytics

// PushService handles registering push notification tokens with TBA and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject {
    
    private enum DefaultKeys: String {
        case pendingRegisterPushToken = "kPendingPushToken"
        case pendingUnregisterPushTokens = "kPendingUnregisterPushTokens"
    }
    
    private static var pendingRegisterPushToken: String? {
        get {
            return UserDefaults.standard.string(forKey: DefaultKeys.pendingRegisterPushToken.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: DefaultKeys.pendingRegisterPushToken.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    private static var pendingUnregisterPushTokens: Set<String> {
        get {
            let arr = UserDefaults.standard.array(forKey: DefaultKeys.pendingUnregisterPushTokens.rawValue) as? [String] ?? []
            return Set(arr)
        }
        set {
            let arr = Array(newValue)
            UserDefaults.standard.set(arr, forKey: DefaultKeys.pendingUnregisterPushTokens.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    override init() {
        super.init()

        // Watch for MyTBA Authentication to process pending registrations
        MyTBA.shared.authenticationProvider.add(observer: self)
    }
    
    deinit {
        MyTBA.shared.authenticationProvider.remove(observer: self)
    }
    
    static func registerPushToken(_ token: String) {
        if MyTBA.shared.authentication == nil {
            // Not authenticated to MyTBA - save token for registration once we're auth'd
            pendingRegisterPushToken = token
        } else {
            _ = MyTBA.shared.register(token) { (error) in
                if let error = error {
                    Crashlytics.sharedInstance().recordError(error)
                }
                // Either save or remove our pending push token as necessary
                pendingRegisterPushToken = (error != nil ? token : nil)
            }
        }
    }
    
    private static func registerPendingPushToken() {
        guard let pendingRegisterPushToken = pendingRegisterPushToken else {
            return
        }
        registerPushToken(pendingRegisterPushToken)
    }
    
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

    static func requestAuthorizationForNotifications(_ completion: ((Error?) -> ())?) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            if let completion = completion {
                completion(error)
            }
        }
    }
    
}

extension PushService: MyTBAAuthenticationObservable {
    
    func authenticated() {
        PushService.registerPendingPushToken()
    }
    
    func unauthenticated() {
        // TODO: By the nature of unregister being hooked up to unauth'd... won't this ALWAYS fail?
        // THINK about maybe making sure we don't get push notifications anymore locally
        if let currentPushToken = Messaging.messaging().fcmToken {
            PushService.unregisterPushToken(currentPushToken)
        }
    }
}
