import XCTest
@testable import TBA

class UIImageTBATests: XCTestCase {

    func test_eventIcon() {
        XCTAssertNotNil(UIImage.eventIcon)
    }

    func test_teamIcon() {
        XCTAssertNotNil(UIImage.teamIcon)
    }

}
