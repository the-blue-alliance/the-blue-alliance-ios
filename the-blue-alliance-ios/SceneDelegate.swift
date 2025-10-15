import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - View Hiearchy

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("openURLContexts")
        print(URLContexts)
    }

    // MARK: - UIWindowSceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
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

