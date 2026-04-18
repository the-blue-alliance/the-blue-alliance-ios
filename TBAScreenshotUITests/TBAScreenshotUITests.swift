import XCTest

final class TBAScreenshotUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        snapshot("01_events")
        app.cells["cell.event.first"].tap()
        snapshot("02_team")
    }

}
