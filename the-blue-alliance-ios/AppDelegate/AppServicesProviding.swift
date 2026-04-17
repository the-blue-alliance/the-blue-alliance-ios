import FirebaseMessaging
import MyTBAKit
import UIKit

enum PendingAlert {
    case minVersion(currentAppVersion: Int)
    case fmsStatus(isDatafeedDown: Bool)
}

protocol AppServicesProviding: AnyObject {
    var dependencies: Dependencies { get }
    var pushService: PushService { get }
    var fcmTokenProvider: any FCMTokenProvider { get }
    var pendingAlerts: [PendingAlert] { get set }
}

protocol SceneAlertPresenting: AnyObject {
    func present(_ alert: PendingAlert)
}

extension UIApplication {
    var appServices: any AppServicesProviding {
        guard let provider = delegate as? any AppServicesProviding else {
            fatalError("UIApplicationDelegate must conform to AppServicesProviding")
        }
        return provider
    }
}
