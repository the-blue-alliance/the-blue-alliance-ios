import Firebase
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseMessaging
import GoogleSignIn
import MyTBAKit
import Photos
import TBAAPI
import TBAUtils
import UIKit
import UserNotifications

let kNoSelectionNavigationController = "NoSelectionNavigationController"

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - View Hierarchy

    // Root VC on iPhone: a tab bar controller, iPad: a split view controller
    lazy private var rootViewController: UIViewController & RootController = {
        if UIDevice.isPhone {
            return rootViewControllerPhone
        } else if UIDevice.isPad {
            return rootViewControllerPad
        }
        fatalError("userInterfaceIdiom \(UIDevice.current.userInterfaceIdiom) unsupported")
    }()
    lazy private var rootViewControllerPhone: PhoneRootViewController = {
        return PhoneRootViewController(fcmTokenProvider: messaging,
                                       myTBA: myTBA,
                                       myTBAStores: myTBAStores,
                                       pasteboard: pasteboard,
                                       photoLibrary: photoLibrary,
                                       pushService: pushService,
                                       statusService: statusService,
                                       urlOpener: urlOpener,
                                       dependencies: dependencies)
    }()
    lazy private var rootViewControllerPad: PadRootViewController = {
        return PadRootViewController(fcmTokenProvider: messaging,
                                       myTBA: myTBA,
                                       myTBAStores: myTBAStores,
                                       pasteboard: pasteboard,
                                       photoLibrary: photoLibrary,
                                       pushService: pushService,
                                       statusService: statusService,
                                       urlOpener: urlOpener,
                                       dependencies: dependencies)
    }()

    // MARK: - Services
    private lazy var dependencies = Dependencies(errorRecorder: errorRecorder,
                                                 api: api,
                                                 userDefaults: userDefaults)
    // Owned here and wrapped in a MyTBAStores bag so the myTBA-related screens
    // can thread both stores as one init param. Not in Dependencies — only a
    // handful of screens care.
    let favoritesStore = FavoritesStore()
    let subscriptionsStore = SubscriptionsStore()
    lazy var myTBAStores: MyTBAStores = MyTBAStores(favorites: favoritesStore, subscriptions: subscriptionsStore)
    private let errorRecorder = TBAErrorRecorder()
    lazy var messaging: Messaging = Messaging.messaging()
    lazy var myTBA: MyTBA = {
        return MyTBA(uuid: UIDevice.current.identifierForVendor!.uuidString,
                     deviceName: UIDevice.current.name,
                     fcmTokenProvider: messaging)
    }()
    let pasteboard = UIPasteboard.general
    let photoLibrary = PHPhotoLibrary.shared()
    lazy var remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    var api: TBAAPI!
    let userDefaults: UserDefaults = UserDefaults.standard
    let urlOpener: URLOpener = UIApplication.shared

    lazy var pushService: PushService = {
        return PushService(errorRecorder: errorRecorder,
                           myTBA: myTBA,
                           retryService: RetryService())
    }()
    lazy var remoteConfigService: RemoteConfigService = {
        return RemoteConfigService(errorRecorder: errorRecorder,
                                   remoteConfig: remoteConfig,
                                   retryService: RetryService())
    }()
    lazy var statusService: StatusService = {
        return StatusService(errorRecorder: errorRecorder,
                             api: api,
                             retryService: RetryService())
    }()

    // A completion block for registering for remote notifications
    var registerForRemoteNotificationsCompletion: ((Error?) -> ())?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Wipe the legacy Core Data SQLite files once per upgrade. Must run
        // before anything else touches the app group.
        LegacyCoreDataCleanup.run(userDefaults: userDefaults)

        AppDelegate.setupAppearance()

        // Setup a dummy launch screen in our window while we're doing setup tasks
        window = UIWindow()
        guard let window = window else {
            fatalError("window should be window")
        }
        window.rootViewController = launchViewController
        window.makeKeyAndVisible()

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

        // Listen for changes to FMS availability
        registerForFMSStatusChanges()
        registerForStatusChanges()

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

        remoteConfigService.registerRetryable(initiallyRetry: true)
        statusService.registerRetryable(initiallyRetry: true)

        // Check our minimum app version
        if !AppDelegate.isAppVersionSupported(minimumAppVersion: statusService.status.minAppVersion) {
            showMinimumAppVersionAlert(currentAppVersion: statusService.status.latestAppVersion)
            return true
        }

        guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
            fatalError("Unable to snapshot root view controller")
        }
        rootViewController.view.addSubview(snapshot)
        window.rootViewController = rootViewController

        // 0.35 is an iOS animation magic number... for now
        UIView.transition(with: snapshot, duration: 0.35, options: .transitionCrossDissolve, animations: {
            snapshot.layer.opacity = 0
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
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

    private static func showMinimumAppAlert(appStoreID: String, currentAppVersion: Int, in window: UIWindow) {
        showRootAlertView(title: "Unsupported App Version", message: "Your version (\(currentAppVersion)) of The Blue Alliance for iOS is no longer supported - please visit the App Store to update to the latest version", in: window, handler: nil)
    }

    private static func showRootAlertView(title: String, message: String, in window: UIWindow, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        window.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    private func setupPushServiceDelegates() {
        messaging.delegate = pushService
        UNUserNotificationCenter.current().delegate = pushService
        myTBA.authenticationProvider.add(observer: pushService)
    }

    private func setupPreviousAuthentication() {
        if Auth.auth().currentUser == nil, GIDSignIn.sharedInstance.hasPreviousSignIn() {
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

    private var launchViewController: UIViewController {
        let launchStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        guard let launchViewController = launchStoryboard.instantiateInitialViewController() else {
            fatalError("Unable to load launch view controller")
        }
        return launchViewController
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

extension AppDelegate {

    static func isAppVersionSupported(minimumAppVersion: Int) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("-testUnsupportedVersion") {
            return true
        }

        return Bundle.main.buildVersionNumber >= minimumAppVersion
    }

    func showMinimumAppVersionAlert(currentAppVersion: Int) {
        guard let window = window else {
            return
        }

        DispatchQueue.main.async {
            AppDelegate.showMinimumAppAlert(appStoreID: "1441973916", currentAppVersion: currentAppVersion, in: window)
        }
    }

}

extension AppDelegate: StatusSubscribable {

    func statusChanged(status: AppStatus) {
        if !AppDelegate.isAppVersionSupported(minimumAppVersion: status.minAppVersion) {
            showMinimumAppVersionAlert(currentAppVersion: statusService.status.latestAppVersion)
        }
    }

}

extension AppDelegate: FMSStatusSubscribable {

    func fmsStatusChanged(isDatafeedDown: Bool) {
        if isDatafeedDown == false {
            return
        }

        let alertController = UIAlertController(title: "FIRST's servers are down",
                                                message: "We rely on FIRST to provide scores, ranking, and more. Unfortunately, FIRST's servers are broken right now, so we can't get the latest updates. The information you see here may be out of date.",
                                                preferredStyle: .alert)
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

}

// Make Messaging conform to FCMTokenProvider for MyTBAKit
extension Messaging: FCMTokenProvider {}

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
