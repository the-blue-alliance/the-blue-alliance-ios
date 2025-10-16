import SwiftUI
import TBAAPI
import UIKit

@main
struct TBAApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @Environment(\.scenePhase) private var scenePhase

    private let secrets = Secrets()
    private let api: TBAAPI
    private let statusService: StatusService

    init() {
        self.api = TBAAPI(apiKey: secrets.tbaAPIKey)
        self.statusService = StatusService(api: api, userDefaults: .standard)
    }

    var body: some Scene {
        WindowGroup {
            PhoneView()
        }
        .environment(\.api, api)
        // .environment(\.statusService, statusService)
    }
}

import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // TODO: Add some code to delete the previous Core Data store

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

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    // MARK: Private Methods

    private func setupWindow(_ window: UIWindow) {
        Task {
            // TODO: Show/register for isDatafeedDown
        }
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
