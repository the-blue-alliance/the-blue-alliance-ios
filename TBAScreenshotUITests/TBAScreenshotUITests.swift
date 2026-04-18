import XCTest

final class TBAScreenshotUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshots() {
        let app = XCUIApplication(bundleIdentifier: "com.the-blue-alliance.tba")
        setupSnapshot(app)
        app.launch()
        snapshot("01_events")
        app.cells["event.2026mimtp"].tap()
        snapshot("02_team")
    }

}
