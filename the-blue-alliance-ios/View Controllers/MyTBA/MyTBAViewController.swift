import UIKit
import UserNotifications

class MyTBAViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, _) in }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
}
