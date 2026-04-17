import GoogleSignIn
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SceneAlertPresenting {

    var window: UIWindow?
    private weak var fmsDownAlert: UIAlertController?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let services = UIApplication.shared.appServices
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = PhoneRootViewController(fcmTokenProvider: services.fcmTokenProvider,
                                                            pushService: services.pushService,
                                                            dependencies: services.dependencies)
        window.makeKeyAndVisible()
        self.window = window

        if !AppDelegate.isAppVersionSupported(minimumAppVersion: services.dependencies.statusService.status.minAppVersion) {
            present(.minVersion(currentAppVersion: services.dependencies.statusService.status.latestAppVersion))
        }

        if !connectionOptions.urlContexts.isEmpty {
            self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for ctx in URLContexts {
            _ = GIDSignIn.sharedInstance.handle(ctx.url)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        var services = UIApplication.shared.appServices
        let queued = services.pendingAlerts
        services.pendingAlerts.removeAll()
        queued.forEach { present($0) }
    }

    func present(_ alert: PendingAlert) {
        guard let root = window?.rootViewController else { return }
        switch alert {
        case .minVersion(let currentAppVersion):
            DispatchQueue.main.async {
                let controller = UIAlertController(
                    title: "Unsupported App Version",
                    message: "Your version (\(currentAppVersion)) of The Blue Alliance for iOS is no longer supported - please visit the App Store to update to the latest version",
                    preferredStyle: .alert
                )
                root.present(controller, animated: true)
            }
        case .fmsStatus(let isDatafeedDown):
            if isDatafeedDown {
                guard fmsDownAlert == nil else { return }
                let controller = UIAlertController(
                    title: "FIRST's servers are down",
                    message: "We rely on FIRST to provide scores, ranking, and more. Unfortunately, FIRST's servers are broken right now, so we can't get the latest updates. The information you see here may be out of date.",
                    preferredStyle: .alert
                )
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                fmsDownAlert = controller
                root.present(controller, animated: true)
            } else {
                fmsDownAlert?.dismiss(animated: true)
                fmsDownAlert = nil
            }
        }
    }

}
