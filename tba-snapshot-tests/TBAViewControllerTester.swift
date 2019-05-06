import Foundation
import UIKit
import XCTest

class TBAViewControllerTester<T: UIViewController> {

    private(set) var window: UIWindow!

    init(withViewController rootViewController: T) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        window.rootViewController = rootViewController

        // Manually load our view controller, since it's not managed by the navigation controller or window automatically
        if rootViewController is UINavigationController {
            let navigationController = rootViewController as! UINavigationController
            let viewController = navigationController.topViewController!
            _ = viewController.view
        }
    }

    deinit {
        window.rootViewController = nil
        window.isHidden = true
        self.window = nil
    }

    /*
     Making an active decision not to use these methods to drive the view lifecycle, and let our view
     lifecycle be driven by the UIWindow and us manually.
    */
    /*
    private func appearViewLifecyle(_ viewController: UIViewController) {
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }

    private func disappearViewLifecycle(_ viewController: UIViewController) {
        viewController.viewWillDisappear(false)
        viewController.viewDidDisappear(false)
    }
    */

}
