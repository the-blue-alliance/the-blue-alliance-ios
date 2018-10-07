import XCTest
import UIKit

class MockNavigationController: UINavigationController {

    var presentCalled: ((UIViewController) -> ())?
    var showDetailViewControllerCalled: ((UIViewController) -> ())?

    var dismissExpectation: XCTestExpectation?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentCalled?(viewControllerToPresent)
    }

    override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        showDetailViewControllerCalled?(vc)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissExpectation?.fulfill()
    }
}
