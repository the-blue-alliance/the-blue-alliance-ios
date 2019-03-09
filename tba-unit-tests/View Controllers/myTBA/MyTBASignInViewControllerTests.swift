import CoreData
import XCTest
@testable import TBA

class MyTBASignInViewControllerTests: TBATestCase {

    override func setUp() {
        super.setUp()
    }

    func test_snapshot() {
        let signInViewController = MyTBASignInViewController()
        verifyView(signInViewController.view)

        // Fake rotate
        signInViewController.view.frame = CGRect(x: 0, y: 0, width: signInViewController.view.frame.height, height: signInViewController.view.frame.width)
        verifyView(signInViewController.view, identifier: "rotated")

        // Fake compact trait collection
        signInViewController.view.frame = CGRect(x: 0, y: 0, width: signInViewController.view.frame.height, height: signInViewController.view.frame.width)
        signInViewController.hideOrShowImageViews(for: UITraitCollection(verticalSizeClass: .compact))
        verifyView(signInViewController.view, identifier: "compact")
    }

}
