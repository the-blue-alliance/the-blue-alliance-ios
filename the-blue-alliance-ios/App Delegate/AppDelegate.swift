import CoreData
import Crashlytics
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import GoogleSignIn
import UIKit
import UserNotifications

let kNoSelectionNavigationController = "NoSelectionNavigationController"

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - View Hiearchy

    // Root VC is a split view controller, with the left side being a tab bar,
    // and the right side being a navigation controller
    lazy private var rootSplitViewController: UISplitViewController = { [unowned self] in
        let splitViewController = UISplitViewController()

        let eventsViewController = EventsContainerViewController(remoteConfig: remoteConfigService.remoteConfig,
                                                                 urlOpener: urlOpener,
                                                                 persistentContainer: persistentContainer,
                                                                 tbaKit: tbaKit,
                                                                 userDefaults: userDefaults)
        let teamsViewController = TeamsContainerViewController(remoteConfig: remoteConfigService.remoteConfig,
                                                               urlOpener: urlOpener,
                                                               persistentContainer: persistentContainer,
                                                               tbaKit: tbaKit,
                                                               userDefaults: userDefaults)
        let districtsViewController = DistrictsContainerViewController(remoteConfig: remoteConfigService.remoteConfig,
                                                                       urlOpener: urlOpener,
                                                                       persistentContainer: persistentContainer,
                                                                       tbaKit: tbaKit,
                                                                       userDefaults: userDefaults)
        let settingsViewController = SettingsViewController(urlOpener: urlOpener,
                                                            metadata: reactNativeMetadata,
                                                            persistentContainer: persistentContainer,
                                                            userDefaults: userDefaults)
        let rootViewControllers: [UIViewController] = [eventsViewController, teamsViewController, districtsViewController, settingsViewController]
        tabBarController.viewControllers = rootViewControllers.compactMap({ (viewController) -> UIViewController? in
            let navigationController = UINavigationController(rootViewController: viewController)
            return navigationController
        })

        splitViewController.viewControllers = [tabBarController, emptyNavigationController]

        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.delegate = self

        return splitViewController
    }()
    private let tabBarController = UITabBarController()
    lazy var emptyNavigationController: UINavigationController = {
        guard let emptyViewController = Bundle.main.loadNibNamed("EmptyViewController", owner: nil, options: nil)?.first as? UIViewController else {
            fatalError("Unable to load empty view controller")
        }

        let navigationController = UINavigationController(rootViewController: emptyViewController)
        navigationController.restorationIdentifier = kNoSelectionNavigationController

        return navigationController
    }()

    // MARK: - Services

    lazy var persistentContainer: TBAPersistenceContainer = {
        return TBAPersistenceContainer()
    }()
    var tbaKit: TBAKit!
    let userDefaults: UserDefaults = UserDefaults.standard
    let urlOpener: URLOpener = UIApplication.shared

    lazy var pushService: PushService = {
        return PushService(userDefaults: userDefaults,
                           myTBA: MyTBA.shared,
                           retryService: RetryService())
    }()
    lazy var realtimeDatabaseService: RealtimeDatabaseService = {
        return RealtimeDatabaseService(databaseReference: Database.database().reference())
    }()
    lazy var remoteConfigService: RemoteConfigService = {
        return RemoteConfigService(remoteConfig: RemoteConfig.remoteConfig(),
                                   retryService: RetryService())
    }()
    lazy var reactNativeService: ReactNativeService = {
        return ReactNativeService(fileManager: FileManager.default,
                                  firebaseStorage: Storage.storage(),
                                  firebaseOptions: FirebaseOptions.defaultOptions(),
                                  metadata: reactNativeMetadata,
                                  retryService: RetryService())
    }()
    lazy var reactNativeMetadata: ReactNativeMetadata = {
        return ReactNativeMetadata(userDefaults: userDefaults)
    }()
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

        let secrets = Secrets()
        tbaKit = TBAKit(apiKey: secrets.tbaAPIKey)

        // Setup our React Native service
        reactNativeService.registerRetryable(initiallyRetry: true)

        // Listen for changes to FMS availability
        registerForFMSStatusChanges()

        // Our app setup operation will load our persistent stores, fetch our remote config, propogate persistance container
        let appSetupOperation = AppSetupOperation(persistentContainer: persistentContainer,
                                                  remoteConfigService: remoteConfigService)
        weak var weakAppSetupOperation = appSetupOperation
        appSetupOperation.completionBlock = { [unowned self] in
            if let error = weakAppSetupOperation?.completionError as NSError? {
                Crashlytics.sharedInstance().recordError(error)
                DispatchQueue.main.async {
                    AppDelegate.showFatalError(error, in: window)
                }
            } else if let buildVersionNumber = Bundle.main.buildVersionNumber,
                !self.isAppVersionSupported(buildVersionNumber, remoteConfig: self.remoteConfigService.remoteConfig) {
                // App build is less than minimum app version - abort
                let appStoreID = self.remoteConfigService.remoteConfig.appStoreID
                DispatchQueue.main.async {
                    AppDelegate.showMinimumAppAlert(appStoreID: appStoreID,
                                                    currentAppVersion: buildVersionNumber,
                                                    in: window)
                }
            } else {
                self.remoteConfigService.registerRetryable()

                DispatchQueue.main.async {
                    guard let window = self.window else {
                        fatalError("Window not setup when setting root vc")
                    }
                    guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
                        fatalError("Unable to snapshot root view controller")
                    }
                    self.rootSplitViewController.view.addSubview(snapshot)
                    window.rootViewController = self.rootSplitViewController

                    if self.remoteConfigService.remoteConfig.myTBAEnabled {
                        self.setupMyTBA()
                    }

                    // 0.35 is an iOS animation magic number... for now
                    UIView.transition(with: snapshot, duration: 0.35, options: .transitionCrossDissolve, animations: {
                        snapshot.layer.opacity = 0;
                    }, completion: { (status) in
                        snapshot.removeFromSuperview()
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
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }

    // MARK: Private

    private func isAppVersionSupported(_ version: Int, remoteConfig: RemoteConfig) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("-testUnsupportedVersion") {
            return false
        }
        return version >= self.remoteConfigService.remoteConfig.minimumAppVersion
    }

    private static func showFatalError(_ error: NSError, in window: UIWindow) {
        showRootAlertView(title: "Error Loading Data",
                          message: "There was an error loading local data - try reinstalling The Blue Alliance",
                          in: window) { (_) in
                            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }

    private static func showMinimumAppAlert(appStoreID: String, currentAppVersion: Int, in window: UIWindow) {
        showRootAlertView(title: "Unsupported App Version",
                          message: "Your version (\(currentAppVersion)) of The Blue Alliance for iOS is no longer supported - please visit the App Store to update to the latest version",
                          in: window) { (_) in
                            if let url = URL(string: "https://itunes.apple.com/app/id\(appStoreID)") {
                                UIApplication.shared.open(url, options: [:], completionHandler: { (_) in
                                    fatalError("Unsupported app version \(currentAppVersion)")
                                })
                            } else {
                                fatalError("Unsupported app version \(currentAppVersion)")
                            }
        }
    }

    private static func showRootAlertView(title: String, message: String, in window: UIWindow, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: handler))
        window.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    private static func setupPushServiceDelegates(with pushService: PushService) {
        Messaging.messaging().delegate = pushService
        UNUserNotificationCenter.current().delegate = pushService
        MyTBA.shared.authenticationProvider.add(observer: pushService)
    }

    private func setupGoogleAuthentication() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        // If we're authenticated with Google but don't have a Firebase user, get a Firebase user
        if GIDSignIn.sharedInstance().hasAuthInKeychain() && Auth.auth().currentUser == nil {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }

    private var launchViewController: UIViewController {
        let launchStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        guard let launchViewController = launchStoryboard.instantiateInitialViewController() else {
            fatalError("Unable to load launch view controller")
        }
        return launchViewController
    }

    private func setupMyTBA() {
        let myTBAViewController = MyTBAViewController(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        tabBarController.viewControllers?.append(myTBAViewController)

        // Assign our Push Service as a delegate to all push-related classes
        AppDelegate.setupPushServiceDelegates(with: pushService)
        // Kickoff background myTBA/Google sign in, along with setting up delegates
        setupGoogleAuthentication()
    }

    static func setupAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()

        navigationBarAppearance.barTintColor = UIColor.primaryBlue
        navigationBarAppearance.tintColor = UIColor.white
        // Remove the shadow for a more seamless split between navigation bar and segmented controls
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = .white
    }

}

extension AppDelegate: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // Don't respond to errors from signInSilently or a user cancelling a sign in
        if let error = error as NSError?, (error.code == GIDSignInErrorCode.canceled.rawValue || error.code == GIDSignInErrorCode.canceled.rawValue) {
            return
        } else if let error = error {
            Crashlytics.sharedInstance().recordError(error)
            if let signInDelegate = GIDSignIn.sharedInstance().uiDelegate as? UIViewController & Alertable {
                signInDelegate.showErrorAlert(with: "Error authorizing notifications - \(error.localizedDescription)")
            }
            return
        }

        guard let authentication = user.authentication else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { (_, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
                if let signInDelegate = GIDSignIn.sharedInstance().uiDelegate as? UIViewController & Alertable {
                    signInDelegate.showErrorAlert(with: "Error signing in to Firebase - \(error.localizedDescription)")
                }
            } else {
                PushService.requestAuthorizationForNotifications { (error) in
                    if let error = error, let signInDelegate = GIDSignIn.sharedInstance().uiDelegate as? UIViewController & Alertable {
                        signInDelegate.showErrorAlert(with: "Error authorizing notifications - \(error.localizedDescription)")
                    }
                }
            }
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
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

}

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        // If our split view controller is collapsed and we're trying to show a detail view,
        // push it on the master navigation stack
        if splitViewController.isCollapsed,
            // Need to get the VC for the currently selected tab...
            let masterNavigationController = tabBarController.selectedViewController as? UINavigationController {
            // We want to push the view controller, but make sure we're not pushing something in a nav controller
            guard let detailNavigationController = vc as? UINavigationController else {
                return false
            }

            guard let detailViewController = detailNavigationController.viewControllers.first else {
                return false
            }

            masterNavigationController.show(detailViewController, sender: nil)

            return true
        }

        return false
    }

    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        // If collapsing and detail view controller is not a no selection navigation view controller,
        // push the first view controller on to primary navigation view controller and return
        // the primary tab bar controller
        if let detailNavigationController = splitViewController.viewControllers.last as? UINavigationController,
            detailNavigationController.restorationIdentifier != kNoSelectionNavigationController {
            // This is a view controller we want to push
            if let masterNavigationController = tabBarController.selectedViewController as? UINavigationController {
                // Add the detail navigation controller stack to our root navigation controller
                masterNavigationController.viewControllers += detailNavigationController.viewControllers
                return tabBarController
            }
        }

        return splitViewController.viewControllers.first
    }

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        // If our primary view controller is not a no selection view controller, pop the old one, return the tab bar,
        // and setup the detail view controller to be the primary view controller
        //
        // Otherwise, return our detail
        if let masterNavigationController = tabBarController.selectedViewController as? UINavigationController,
            masterNavigationController.topViewController?.restorationIdentifier != kNoSelectionNavigationController {
            // We want to seperate this event view controller in to the detail view controller
            if let detailViewControllers = masterNavigationController.popToRootViewController(animated: true) {
                let detailNavigationController = UINavigationController()
                detailNavigationController.viewControllers = detailViewControllers
                splitViewController.viewControllers = [tabBarController, detailNavigationController]

                return detailNavigationController
            }
        }

        return emptyNavigationController
    }

}
