import XCTest
@testable import TBA

class UIBarButtonItemTBATests: XCTestCase {

    func test_activityIndicatorBarButtonItem() {
        let activityIndicatorBarButtonItem = UIBarButtonItem.activityIndicatorBarButtonItem()
        XCTAssertNotNil(activityIndicatorBarButtonItem)
        XCTAssert(activityIndicatorBarButtonItem.customView is UIActivityIndicatorView)
        let activityIndicatorView = activityIndicatorBarButtonItem.customView as! UIActivityIndicatorView
        XCTAssert(activityIndicatorView.isAnimating)
        // TODO: Snapshot test...
    }

}
