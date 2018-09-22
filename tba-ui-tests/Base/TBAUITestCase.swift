import XCTest

class TBAUITestCase: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        app = XCUIApplication()
        app.launch()

        // Wait for our main app UI to setup
        XCTAssert(XCUIApplication().tabBars.firstMatch.waitForExistence(timeout: 30))
    }

}
