import UIKit
import CoreData
import TBAKit
import Firebase
import Crashlytics
import GoogleSignIn
import UserNotifications

let kNoSelectionNavigationController = "NoSelectionNavigationController"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TBA")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.automaticallyMergesChangesFromParent = true

            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                // https://stackoverflow.com/a/30941356/537341
                var topWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
                topWindow.rootViewController = UIViewController()
                topWindow.windowLevel = UIWindowLevelAlert + 1
                
                let alertController = UIAlertController(title: "Error Loading Data",
                                                        message: "There was an error loading local data - try reinstalling The Blue Alliance",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: { (_) in
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }))
                
                topWindow.makeKeyAndVisible()
                topWindow.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // TODO: Remove this
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/128
        TBAKit.sharedKit.apiKey = "OHBBu0QbDiIJYKhAedTfkTxdrkXde1C21Sr90L1f1Pac4ahl4FJbNptNiXbCSCfH"
        
        if let splitViewController = self.window?.rootViewController as? UISplitViewController {
            splitViewController.preferredDisplayMode = .allVisible
            splitViewController.delegate = self
            
            let tabBarController = splitViewController.viewControllers[0] as! UITabBarController
            for vc in tabBarController.viewControllers! {
                guard let nav = vc as? UINavigationController else {
                    continue
                }

                guard let dataVC = nav.topViewController as? Persistable else {
                    continue
                }
                // TODO: Make sure we only pass this once we have it, as well as a MOC
                // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/165
                dataVC.persistentContainer = persistentContainer
            }
        }
        
        setupAppearance()
        
        FirebaseApp.configure()
        // Setup Remote Config
        RemoteConfig.setupRemoteConfig()

        // Assign our Push Notification delegates
        Messaging.messaging().delegate = PushService.shared
        UNUserNotificationCenter.current().delegate = PushService.shared

        // Attempt to download our newest React Native bundle
        ReactNativeService.updateReactNativeBundle()

        // myTBA/Google Sign In
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }
        
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
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    // MARK: Private
    
    func setupAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.barTintColor = UIColor.primaryBlue
        navigationBarAppearance.tintColor = UIColor.white
        // Remove the shadow for a more seamless split between navigation bar and segmented controls
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
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
        MyTBA.shared.authentication = authentication.fetcherAuthorizer()
        PushService.requestAuthorizationForNotifications { (error) in
            if let error = error, let signInDelegate = GIDSignIn.sharedInstance().uiDelegate as? UIViewController & Alertable {
                signInDelegate.showErrorAlert(with: "Error authorizing notifications - \(error.localizedDescription)")
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
        
        return emptyDetailViewController()
    }

    public func emptyDetailViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: kNoSelectionNavigationController)
    }

}
