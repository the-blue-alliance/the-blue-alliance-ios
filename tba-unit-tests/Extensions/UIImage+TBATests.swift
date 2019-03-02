import XCTest
@testable import The_Blue_Alliance

class UIImageTBATests: XCTestCase {

    func test_eventIcon() {
        XCTAssertNotNil(UIImage.eventIcon)
    }

    func test_teamIcon() {
        XCTAssertNotNil(UIImage.teamIcon)
    }

}
