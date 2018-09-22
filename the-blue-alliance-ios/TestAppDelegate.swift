import Firebase
import Foundation

class TestAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup our Firebase app - make sure this is called before other Firebase setup
        FirebaseApp.configure()
        return true
    }

}
