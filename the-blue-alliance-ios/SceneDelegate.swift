import GoogleSignIn
import MyTBAKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    // MARK: - View Hiearchy

    private var launchViewController: UIViewController {
        let launchStoryboard = UIStoryboard(name: "LaunchStoryboard", bundle: nil)
        guard let launchViewController = launchStoryboard.instantiateInitialViewController() else {
            fatalError("Unable to load launch view controller")
        }
        return launchViewController
    }

    // MARK: - UIWindowSceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Setup a dummy launch screen in our window while we're doing setup tasks
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = launchViewController

        self.window = window
        window.makeKeyAndVisible()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Cannot get reference to AppDelegate")
        }

        Task {
            do {
                try await appDelegate.loadCoreData()
                showMainViewController(with: appDelegate)
            } catch {
                showFatalError(error as NSError)
            }
        }
    }

    // MARK: - Scene-Specific URL Handling

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        GIDSignIn.sharedInstance.handle(urlContext.url)
    }

    // MARK: - Private Methods

    @MainActor
    func showMainViewController(with appDelegate: AppDelegate) {
        let rootViewController: UIViewController = {
            // Root VC on iPhone: a tab bar controller, iPad: a split view controller
            if UIDevice.isPhone {
                return PhoneRootViewController(
                    fcmTokenProvider: appDelegate.messaging,
                    myTBA: appDelegate.myTBA,
                    pasteboard: appDelegate.pasteboard,
                    // photoLibrary: appDelegate.photoLibrary,
                    pushService: appDelegate.pushService,
                    searchService: appDelegate.searchService,
                    statusService: appDelegate.statusService,
                    urlOpener: appDelegate.urlOpener,
                    dependencies: appDelegate.dependencies
                )
            } else if UIDevice.isPad {
                return PadRootViewController(
                    fcmTokenProvider: appDelegate.messaging,
                    myTBA: appDelegate.myTBA,
                    pasteboard: appDelegate.pasteboard,
                    // photoLibrary: dependencyProvider.photoLibrary,
                    pushService: appDelegate.pushService,
                    searchService: appDelegate.searchService,
                    statusService: appDelegate.statusService,
                    urlOpener: appDelegate.urlOpener,
                    dependencies: appDelegate.dependencies
                )
            }
            fatalError("userInterfaceIdiom \(UIDevice.current.userInterfaceIdiom) unsupported")
        }()

        guard let window = self.window else {
            fatalError("Window not setup when setting root vc")
        }
        guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
            fatalError("Unable to snapshot root view controller")
        }
        rootViewController.view.addSubview(snapshot)
        window.rootViewController = rootViewController

        // 0.35 is an iOS animation magic number... for now
        UIView.transition(with: snapshot, duration: 0.35, options: .transitionCrossDissolve, animations: {
            snapshot.layer.opacity = 0;
        }, completion: { (status) in
            snapshot.removeFromSuperview()
        })
    }

    private func showFatalError(_ error: NSError) {
        showRootAlertView(title: "Error Loading Data",
                          message: "There was an error loading local data - try reinstalling The Blue Alliance",
        ) { _ in
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }

    private func showRootAlertView(title: String, message: String, handler: ((_: UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

}
