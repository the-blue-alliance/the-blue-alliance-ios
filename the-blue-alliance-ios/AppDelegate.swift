// import Firebase
// import FirebaseAnalytics
// import FirebaseCrashlytics
import TBAAPI
// import GoogleSignIn
import UIKit

import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var api: TBAAPI = {
        let secrets = Secrets()
        return TBAAPI(apiKey: secrets.tbaAPIKey)
    }()
    lazy var searchService: SearchService = {
        return SearchService(
            api: api
        )
    }()
    lazy var statusService: StatusService = {
        return StatusService(
            api: api,
            userDefaults: UserDefaults.standard
        )
    }()

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.setupAppearance()

        /*
        // Setup our Firebase app - make sure this is called before other Firebase setup
        FirebaseApp.configure()

        // Disable Crashlytics during debug
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #else
        Analytics.setAnalyticsCollectionEnabled(true)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
        */

        Task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                print("didBecomeActiveNotification")
            }
        }
        Task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didEnterBackgroundNotification) {
                print("didEnterBackgroundNotification")
            }
        }
        Task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.willTerminateNotification) {
                print("willTerminateNotification")
            }
        }

        return true
    }

    func setupWindow(_ window: UIWindow) {
        Task {
            // TODO: Show/register for isDatafeedDown
        }
    }

    // MARK: - Internal Methods

    static func setupAppearance() {
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()

            navigationBarAppearance.backgroundColor = UIColor.navigationBarTintColor
            navigationBarAppearance.shadowColor = nil
            navigationBarAppearance.shadowImage = UIImage()
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }

        let navigationBarAppearance = UINavigationBar.appearance()

        navigationBarAppearance.barTintColor = UIColor.navigationBarTintColor
        navigationBarAppearance.tintColor = UIColor.white
        // Remove the shadow for a more seamless split between navigation bar and segmented controls
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()

            tabBarAppearance.selectionIndicatorTintColor = UIColor.tabBarTintColor

            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.isTranslucent = false
        tabBarAppearance.tintColor = UIColor.tabBarTintColor

        let segmentedControlAppearance = UISegmentedControl.appearance()
        segmentedControlAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segmentedControlAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.segmentedControlSelectedColor], for: .selected)
    }

}

/*
private class TBAErrorRecorder: ErrorRecorder {

    func log(_ format: String, _ args: [CVarArg]) {
        #if DEBUG
        print(String(format: format, arguments: args))
        #else
        Crashlytics.crashlytics().log(format: format, arguments: getVaList(args))
        #endif
    }

    func record(_ error: Error) {
        #if DEBUG
        print(error)
        #else
        Crashlytics.crashlytics().record(error: error)
        #endif
    }

}
*/

extension AppDelegate: DependencyProvider {}
