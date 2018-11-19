import XCTest
import UIKit

class MockNavigationController: UINavigationController {

    var presentCalled: ((UIViewController) -> ())?

    var detailViewController: UIViewController?
    var pushedViewController: UIViewController?

    var dismissExpectation: XCTestExpectation?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        presentCalled?(viewControllerToPresent)
    }

    override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        detailViewController = vc
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: animated)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        dismissExpectation?.fulfill()
    }

}
