import CoreData
import Crashlytics
import Firebase
import FirebaseAuth
import FirebaseMessaging
import GoogleSignIn
import TBAKit
import UIKit
import UserNotifications

let kNoSelectionNavigationController = "NoSelectionNavigationController"

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var emptyNavigationController: UINavigationController = {
        guard let emptyViewController = Bundle.main.loadNibNamed("EmptyViewController", owner: nil, options: nil)?.first as? UIViewController else {
            fatalError("Unable to load empty view controller")
        }

        let navigationController = UINavigationController(rootViewController: emptyViewController)
        navigationController.restorationIdentifier = kNoSelectionNavigationController

        return navigationController
    }()
    lazy var persistentContainer: NSPersistentContainer = {
        return NSPersistentContainer(name: "TBA")
    }()
    lazy var pushService: PushService = {
        return PushService(userDefaults: UserDefaults.standard,
                           myTBA: MyTBA.shared,
                           retryService: RetryService())
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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

        // TODO: Load this from some secrets file
        TBAKit.sharedKit.apiKey = "OHBBu0QbDiIJYKhAedTfkTxdrkXde1C21Sr90L1f1Pac4ahl4FJbNptNiXbCSCfH"

        // Assign our Push Service as a delegate to all push-related classes
        AppDelegate.setupPushServiceDelegates(with: pushService)

        // Setup our React Native service
        AppDelegate.setupReactNativeService()

        // Kickoff background myTBA/Google sign in, along with setting up delegates
        setupGoogleAuthentication()

        // Setup our remote config - to be used by our app setup operation
        let remoteConfigService = RemoteConfigService(remoteConfig: RemoteConfig.remoteConfig(),
                                                      retryService: RetryService())
        remoteConfigService.registerRetryable()

        // Our app setup operation will load our persistent stores, fetch our remote config, propogate persistance container
        let appSetupOperation = AppSetupOperation(persistentContainer: persistentContainer,
                                                  remoteConfigService: remoteConfigService)
        weak var weakAppSetupOperation = appSetupOperation
        appSetupOperation.completionBlock = { [weak self] in
            if let error = weakAppSetupOperation?.completionError as NSError? {
                Crashlytics.sharedInstance().recordError(error)
                DispatchQueue.main.async {
                    AppDelegate.showFatalError(error, in: window)
                }
            } else {
                DispatchQueue.main.async {
                    guard let rootSplitViewController = self?.rootSplitViewController else {
                        fatalError("Unable to setup rootSplitViewController")
                    }
                    guard let window = self?.window else {
                        fatalError("Window not setup when setting root vc")
                    }
                    guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
                        fatalError("Unable to snapshot root view controller")
                    }
                    rootSplitViewController.view.addSubview(snapshot)
                    window.rootViewController = rootSplitViewController

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

    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }

    // MARK: Private

    private static func showFatalError(_ error: NSError, in window: UIWindow) {
        let alertController = UIAlertController(title: "Error Loading Data",
                                                message: "There was an error loading local data - try reinstalling The Blue Alliance",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: { (_) in
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }))
        window.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    private static func setupPushServiceDelegates(with pushService: PushService) {
        Messaging.messaging().delegate = pushService
        UNUserNotificationCenter.current().delegate = pushService
        MyTBA.shared.authenticationProvider.add(observer: pushService)
    }

    private static func setupReactNativeService() {
        let reactNativeService = ReactNativeService(userDefaults: UserDefaults.standard,
                                                    fileManager: FileManager.default,
                                                    firebaseStorage: Storage.storage(),
                                                    firebaseOptions: FirebaseOptions.defaultOptions()!,
                                                    retryService: RetryService())
        reactNativeService.registerRetryable(initiallyRetry: true)
    }

    private func setupGoogleAuthentication() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        // If we're authenticated with Google but don't have a Firebase user, get a Firebase user
        if GIDSignIn.sharedInstance().hasAuthInKeychain() && Auth.auth().currentUser == nil {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }

    private static func setupAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()

        navigationBarAppearance.barTintColor = UIColor.primaryBlue
        navigationBarAppearance.tintColor = UIColor.white
        // Remove the shadow for a more seamless split between navigation bar and segmented controls
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    private var launchViewController: UIViewController {
        let launchStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        guard let launchViewController = launchStoryboard.instantiateInitialViewController() else {
            fatalError("Unable to load launch view controller")
        }
        return launchViewController
    }

    private var rootSplitViewController: UISplitViewController {
        // Root VC is a split view controller, with the left side being a tab bar,
        // and the right side being a navigation controller
        let splitViewController = UISplitViewController()

        let mainBundle = Bundle.main
        let tabBarController = UITabBarController()
        let rootStoryboards = [UIStoryboard(name: "EventsStoryboard", bundle: mainBundle),
                               UIStoryboard(name: "TeamsStoryboard", bundle: mainBundle),
                               UIStoryboard(name: "DistrictsStoryboard", bundle: mainBundle),
                               UIStoryboard(name: "MyTBAStoryboard", bundle: mainBundle)]
        tabBarController.viewControllers = rootStoryboards.compactMap({ (storyboard) -> UIViewController? in
            return storyboard.instantiateInitialViewController()
        })
        tabBarController.viewControllers?.forEach({ (viewController) in
            guard let navigationController = viewController as? UINavigationController else {
                fatalError("Root VC in controller should be a navigation controller")
            }
            guard let dataViewController = navigationController.topViewController as? Persistable else {
                fatalError("Root view controller in navigation controller should be data vc")
            }
            dataViewController.persistentContainer = self.persistentContainer
        })
        splitViewController.viewControllers = [tabBarController, emptyNavigationController]

        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.delegate = self

        return splitViewController
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

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        // If our split view controller is collapsed and we're trying to show a detail view,
        // push it on the master navigation stack
        if splitViewController.isCollapsed,
            let masterTabBarController = splitViewController.viewControllers.first as? UITabBarController,
            // Need to get the VC for the currently selected tab...
            let masterNavigationController = masterTabBarController.selectedViewController as? UINavigationController {
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
            if let masterTabBarController = splitViewController.viewControllers.first as? UITabBarController,
                let masterNavigationController = masterTabBarController.selectedViewController as? UINavigationController {
                // Add the detail navigation controller stack to our root navigation controller
                masterNavigationController.viewControllers += detailNavigationController.viewControllers
                return masterTabBarController
            }
        }

        return splitViewController.viewControllers.first
    }

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        // If our primary view controller is not a no selection view controller, pop the old one, return the tab bar,
        // and setup the detail view controller to be the primary view controller
        //
        // Otherwise, return our detail
        if let masterTabViewController = splitViewController.viewControllers.first as? UITabBarController,
            let masterNavigationController = masterTabViewController.selectedViewController as? UINavigationController,
            masterNavigationController.topViewController?.restorationIdentifier != kNoSelectionNavigationController {
            // We want to seperate this event view controller in to the detail view controller
            if let detailViewControllers = masterNavigationController.popToRootViewController(animated: true) {
                let detailNavigationController = UINavigationController()
                detailNavigationController.viewControllers = detailViewControllers
                splitViewController.viewControllers = [masterTabViewController, detailNavigationController]

                return detailNavigationController
            }
        }

        return emptyNavigationController
    }

}
