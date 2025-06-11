import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    weak var dependencyProvider: DependencyProvider!

    // MARK: - View Hiearchy

    private var launchViewController: UIViewController {
        let launchStoryboard = UIStoryboard(name: "LaunchStoryboard", bundle: nil)
        guard let launchViewController = launchStoryboard.instantiateInitialViewController() else {
            fatalError("Unable to load launch view controller")
        }
        return launchViewController
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("openURLContexts")
        print(URLContexts)
    }

    // MARK: - UIWindowSceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Cannot get reference to dependencyProvider")
        }
        self.dependencyProvider = appDelegate

        let rootViewController: UIViewController = {
            // Root VC on iPhone: a tab bar controller, iPad: a split view controller
            if UIDevice.isPhone {
                return PhoneRootViewController(dependencyProvider: appDelegate)
            } else if UIDevice.isPad {
                return PadRootViewController(dependencyProvider: appDelegate)
            }
            fatalError("userInterfaceIdiom \(UIDevice.current.userInterfaceIdiom) unsupported")
        }()

        // Setup a dummy launch screen in our window while we're doing setup tasks
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootViewController

        self.window = window
        window.makeKeyAndVisible()

        appDelegate.setupWindow(window)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // TODO: Disconnect
    }

    // MARK: - Internal Methods

    func transitionToRootViewController() {
        // Note: This is legacy code, and I should just delete it, but I might
        // need it again and I don't wanna go digging through version control
        /*
        if let snapshot = window.snapshotView(afterScreenUpdates: true) {
            rootViewController.view.addSubview(snapshot)
            window.rootViewController = rootViewController

            UIView.transition(with: snapshot, duration: 0.35) {
                snapshot.layer.opacity = 0
            } completion: { _ in
                snapshot.removeFromSuperview()
            }
        } else {
            window.rootViewController = rootViewController
        }
        */
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // This is a GREAT spot to throw some debugging code
        }
        super.motionEnded(motion, with: event)
    }

    fileprivate func presentFMSDownAlert() {
        let alertController = UIAlertController(
            title: "FIRST's servers are down",
            message: "We rely on FIRST to provide scores, ranking, and more. Unfortunately, FIRST's servers are down right now, so we can't get the latest updates. The information you see here may be out of date.",
            preferredStyle: .alert
        )

        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)

        rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

