import CoreData
import CoreSpotlight
import Firebase
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseMessaging
import GoogleSignIn
import MyTBAKit
import Photos
import Search
import TBAData
import TBAKit
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
                                       pasteboard: pasteboard,
                                       photoLibrary: photoLibrary,
                                       pushService: pushService,
                                       searchService: searchService,
                                       statusService: statusService,
                                       urlOpener: urlOpener,
                                       dependencies: dependencies)
    }()
    lazy private var rootViewControllerPad: PadRootViewController = {
        return PadRootViewController(fcmTokenProvider: messaging,
                                       myTBA: myTBA,
                                       pasteboard: pasteboard,
                                       photoLibrary: photoLibrary,
                                       pushService: pushService,
                                       searchService: searchService,
                                       statusService: statusService,
                                       urlOpener: urlOpener,
                                       dependencies: dependencies)
    }()

    // MARK: - Services
    private lazy var dependencies = Dependencies(errorRecorder: errorRecorder,
                                                 persistentContainer: persistentContainer,
                                                 tbaKit: tbaKit,
                                                 userDefaults: userDefaults)
    private let errorRecorder = TBAErrorRecorder()
    lazy var indexDelegate: TBACoreDataCoreSpotlightDelegate = {
        let description = persistentContainer.persistentStoreDescriptions.first!
        let coordinator = persistentContainer.persistentStoreCoordinator
        let spotlightDelegate = TBACoreDataCoreSpotlightDelegate(forStoreWith: description,
                                                                 coordinator: coordinator)
        spotlightDelegate.startSpotlightIndexing()
        return spotlightDelegate
    }()
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
    let photoLibrary = PHPhotoLibrary.shared()
    lazy var remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    var tbaKit: TBAKit!
    let userDefaults: UserDefaults = UserDefaults.standard
    let urlOpener: URLOpener = UIApplication.shared

    lazy var handoffService: HandoffService = {
        return HandoffService(errorRecorder: errorRecorder,
                              persistentContainer: persistentContainer,
                              rootControllerProvider: { [unowned self] in
            return rootViewController
        })
    }()
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
    lazy var searchService: SearchService = {
        return SearchService(application: UIApplication.shared,
                             errorRecorder: errorRecorder,
                             indexDelegate: indexDelegate,
                             persistentContainer: persistentContainer,
                             searchIndex: CSSearchableIndex.default(),
                             statusService: statusService,
                             tbaKit: tbaKit,
                             userDefaults: userDefaults)
    }()
    lazy var statusService: StatusService = {
        return StatusService(errorRecorder: errorRecorder,
                             persistentContainer: persistentContainer,
                             retryService: RetryService(),
                             tbaKit: tbaKit)
    }()

    // A completion block for registering for remote notifications
    var registerForRemoteNotificationsCompletion: ((Error?) -> ())?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
        tbaKit = TBAKit(apiKey: secrets.tbaAPIKey, userDefaults: userDefaults)

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

        // Our app setup operation will load our persistent stores, propogate persistance container
        let appSetupOperation = AppSetupOperation(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        weak var weakAppSetupOperation = appSetupOperation
        appSetupOperation.completionBlock = { [unowned self] in
            if let error = weakAppSetupOperation?.completionError as NSError? {
                errorRecorder.record(error)
                DispatchQueue.main.async {
                    AppDelegate.showFatalError(error, in: window)
                }
            } else {
                self.searchService.refresh()

                // Register retries for our status service on the main thread
                DispatchQueue.main.async {
                    self.remoteConfigService.registerRetryable(initiallyRetry: true)
                    self.statusService.registerRetryable(initiallyRetry: true)

                    // Check our minimum app version
                    if !AppDelegate.isAppVersionSupported(minimumAppVersion: self.statusService.status.minAppVersion) {
                        self.showMinimumAppVersionAlert(currentAppVersion: self.statusService.status.latestAppVersion)
                        return
                    }

                    guard let window = self.window else {
                        fatalError("Window not setup when setting root vc")
                    }
                    guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
                        fatalError("Unable to snapshot root view controller")
                    }
                    self.rootViewController.view.addSubview(snapshot)
                    window.rootViewController = self.rootViewController

                    // 0.35 is an iOS animation magic number... for now
                    UIView.transition(with: snapshot, duration: 0.35, options: .transitionCrossDissolve, animations: {
                        snapshot.layer.opacity = 0;
                    }, completion: { (status) in
                        snapshot.removeFromSuperview()
                        self.handoffService.appSetup = true
                    })
                }
            }
        }
        OperationQueue.main.addOperation(appSetupOperation)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Update anything we want to be fresh
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: Search Delegate Methods

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return handoffService.application(continue: userActivity)
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

    private static func showFatalError(_ error: NSError, in window: UIWindow) {
        showRootAlertView(title: "Error Loading Data",
                          message: "There was an error loading local data - try reinstalling The Blue Alliance",
                          in: window) { (_) in
                            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }

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

    func statusChanged(status: Status) {
        if !AppDelegate.isAppVersionSupported(minimumAppVersion: status.minAppVersion) {
            showMinimumAppVersionAlert(currentAppVersion: statusService.status.latestAppVersion)
        }
    }

}

extension AppDelegate: FMSStatusSubscribable {

    func fmsStatusChanged(isDatafeedDown: Bool) {
        // We could react to hiding/showing something, like Android does
        // Since we're not setup to do this, we'll show an alert view only when the data feed is down
        if isDatafeedDown == false {
            return
        }

        let alertController = UIAlertController(title: "FIRST's servers are down",
                                                message: "We rely on FIRST to provide scores, ranking, and more. Unfortunately, FIRST's servers are broken right now, so we can't get the latest updates. The information you see here may be out of date.",
                                                preferredStyle: .alert)
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

}

// Make Crashlytics conform to ErrorRecorder for TBAData
// extension Crashlytics: ErrorRecorder {}
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
