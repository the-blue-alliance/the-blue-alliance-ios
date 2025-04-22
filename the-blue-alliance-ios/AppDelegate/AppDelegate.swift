import CoreData
import Firebase
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseMessaging
import GoogleSignIn
import MyTBAKit
import Photos
import TBAAPI
import TBAData
import TBAKit
import TBAUtils
import UIKit
import UserNotifications

let kNoSelectionNavigationController = "NoSelectionNavigationController"

class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Services

    lazy var dependencies = Dependencies(
        api: api,
        errorRecorder: errorRecorder,
        persistentContainer: persistentContainer,
        tbaKit: tbaKit,
        userDefaults: userDefaults
    )
    private let errorRecorder = TBAErrorRecorder()
    lazy var messaging: Messaging = Messaging.messaging()
    lazy var myTBA: MyTBA = {
        return MyTBA(uuid: UIDevice.current.identifierForVendor!.uuidString,
                     deviceName: UIDevice.current.name,
                     fcmTokenProvider: messaging)
    }()
    let pasteboard = UIPasteboard.general
    lazy var persistentContainer: TBAPersistenceContainer = {
        let persistentContainer = TBAPersistenceContainer()
        persistentContainer.persistentStoreDescriptions.forEach {
            $0.type = NSSQLiteStoreType
            $0.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }
        return persistentContainer
    }()
    var api: TBAAPI!
    var tbaKit: TBAKit!
    let userDefaults: UserDefaults = UserDefaults.standard
    let urlOpener: URLOpener = UIApplication.shared

    lazy var pushService: PushService = {
        return PushService(errorRecorder: errorRecorder,
                           myTBA: myTBA,
                           retryService: RetryService())
    }()
    lazy var searchService: SearchService = {
        return SearchService(
            api: api,
            retryService: RetryService()
        )
    }()
    lazy var statusService: StatusService = {
        return StatusService(
            api: api,
            retryService: RetryService(),
            userDefaults: userDefaults
        )
    }()

    // A completion block for registering for remote notifications
    var registerForRemoteNotificationsCompletion: ((Error?) -> ())?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.setupAppearance()

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

        let secrets = Secrets()
        api = TBAAPI(apiKey: secrets.tbaAPIKey)
        tbaKit = TBAKit(apiKey: secrets.tbaAPIKey, userDefaults: userDefaults)

        // Listen for changes to FMS availability
        registerForFMSStatusChanges()

        // Assign our Push Service as a delegate to all push-related classes
        setupPushServiceDelegates()
        // Register for remote notifications - don't worry if we fail here
        PushService.registerForRemoteNotifications(nil)

        Auth.auth().addIDTokenDidChangeListener { (_, user) in
            if let user = user {
                user.getIDToken { (token, _) in
                    self.myTBA.authToken = token
                }
            } else {
                self.myTBA.authToken = nil
            }
        }

        // Kickoff background myTBA, along with setting up delegates
        setupPreviousAuthentication()

        statusService.registerRetryable()
        searchService.registerRetryable()

        return true
    }

    public func loadCoreData() async throws {
        let appSetupOperation = AppSetupOperation(persistentContainer: persistentContainer, userDefaults: userDefaults)
        try await appSetupOperation.execute()
    }

    // MARK: Push Delegate Methods

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        registerForRemoteNotificationsCompletion?(error)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        registerForRemoteNotificationsCompletion?(nil)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Remote notification: \(userInfo)")
        completionHandler(.noData)
    }

    // MARK: Private

    private func setupPushServiceDelegates() {
        messaging.delegate = pushService
        UNUserNotificationCenter.current().delegate = pushService
        myTBA.authenticationProvider.add(observer: pushService)
    }

    private func setupPreviousAuthentication() {
        // If we're authenticated with Google but don't have a Firebase user, get a Firebase user
        if Auth.auth().currentUser == nil, GIDSignIn.sharedInstance.hasPreviousSignIn() {
            // TODO: Need to figure out if it's a Google user or an Apple user?
            // I suppose, let's print something here...
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                if let error = error {
                    errorRecorder.record(error)
                    return
                }

                AuthHelper.signInToGoogle(user: user) { [unowned self] success, error in
                    if let error = error {
                        errorRecorder.record(error)
                    }
                    guard success else {
                        return
                    }
                    PushService.requestAuthorizationForNotifications { [unowned self] (_, error) in
                        guard let error = error else {
                            return
                        }
                        errorRecorder.record(error)
                    }
                }
            }
        }
    }

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

extension AppDelegate: FMSStatusSubscribable {

    func fmsStatusChanged(isDatafeedDown: Bool) {
        // We could react to hiding/showing something, like Android does
        // Since we're not setup to do this, we'll show an alert view only when the data feed is down
        if isDatafeedDown == false {
            return
        }

        let connectedScenes = UIApplication.shared.connectedScenes
        guard let windowScene = connectedScenes.first(where: { scene in
            // Ensure the scene is a UIWindowScene (as only these have windows)
            guard let windowScene = scene as? UIWindowScene else { return false }
            // Check if this window scene contains the key window
             return windowScene.windows.first(where: { $0.isKeyWindow }) != nil
        }) as? UIWindowScene else {
            return
        }

        let alertController = UIAlertController(title: "FIRST's servers are down",
                                                message: "We rely on FIRST to provide scores, ranking, and more. Unfortunately, FIRST's servers are broken right now, so we can't get the latest updates. The information you see here may be out of date.",
                                                preferredStyle: .alert)

        windowScene.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

}

// Make Crashlytics conform to ErrorRecorder for TBAData
// extension Crashlytics: ErrorRecorder {}
// Make Messaging conform to FCMTokenProvider for MyTBAKit
extension Messaging: @retroactive FCMTokenProvider {}

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
