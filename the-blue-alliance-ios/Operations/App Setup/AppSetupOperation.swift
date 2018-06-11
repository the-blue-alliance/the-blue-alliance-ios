import CoreData
import Foundation
import UIKit

class AppSetupOperation: TBAOperation {

    var window: UIWindow
    var rootSplitViewController: UISplitViewController
    var persistentContainerOperation: PersistentContainerOperation
    var remoteConfigServiceOperation: RemoteConfigServiceOperation

    let appSetupOperationQueue = OperationQueue()

    init(window: UIWindow, rootSplitViewController: UISplitViewController, persistentContainer: NSPersistentContainer, remoteConfigService: RemoteConfigService) {
        self.window = window
        self.rootSplitViewController = rootSplitViewController
        self.persistentContainerOperation = PersistentContainerOperation(persistentContainer: persistentContainer)
        self.remoteConfigServiceOperation = RemoteConfigServiceOperation(remoteConfigService: remoteConfigService)

        super.init()

        self.persistentContainerOperation.completionBlock = { [unowned persistentContainerOperation] in
            if let error = persistentContainerOperation.completionError as NSError? {
                self.completionError = error
            }
        }
    }

    override func execute() {
        let blockOperation = BlockOperation {
            if self.completionError == nil {
                self.propogatePersistentContainer(to: self.rootSplitViewController)

                DispatchQueue.main.async {
                    let snapshot = self.window.snapshotView(afterScreenUpdates: true)!
                    self.rootSplitViewController.view.addSubview(snapshot)

                    self.window.rootViewController = self.rootSplitViewController
                    // 0.35 is an iOS animation magic number... for now
                    UIView.transition(with: snapshot, duration: 0.35, options: .transitionCrossDissolve, animations: {
                        snapshot.layer.opacity = 0;
                    }, completion: { (status) in
                        snapshot.removeFromSuperview()
                    })
                }
            }
            self.finish()
        }

        let dependentOperations = [persistentContainerOperation, remoteConfigServiceOperation]
        for op in dependentOperations {
            blockOperation.addDependency(op)
        }
        appSetupOperationQueue.addOperations(dependentOperations + [blockOperation], waitUntilFinished: false)
    }

    private func propogatePersistentContainer(to splitViewController: UISplitViewController) {
        guard let tabBarController = splitViewController.viewControllers.first as? UITabBarController else {
            fatalError("No tab bar controller found in root split view controller")
        }
        guard let viewControllers = tabBarController.viewControllers else {
            fatalError("No view controllers found in tab bar controller")
        }

        for vc in viewControllers {
            guard let nav = vc as? UINavigationController else {
                fatalError("\(vc) is a root view controller and should be wrapped in a navigation controller")
            }
            guard let dataVC = nav.topViewController as? Persistable else {
                fatalError("\(vc) is a root view controller and should conform to persistable")
            }
            dataVC.persistentContainer = self.persistentContainerOperation.persistentContainer
        }
    }

}
