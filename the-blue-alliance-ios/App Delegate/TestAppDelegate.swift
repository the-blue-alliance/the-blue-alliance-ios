import Firebase
import Foundation
import UIKit

// TODO: Subclass AppDelegate and override some of the properties to make things testable
class TestAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.setupAppearance()
        // Setup our Firebase app - make sure this is called before other Firebase setup
        FirebaseApp.configure()
        return true
    }

}
