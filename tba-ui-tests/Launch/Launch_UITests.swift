import XCTest

// Test app launch related code
class Launch_UITestCase: XCTestCase {

    lazy var app: XCUIApplication = {
        return XCUIApplication()
    }()

    func test_coreDataError() {
        app.launchArguments.append("-testCoreDataError")
        app.launch()

        let coreDataErrorAlert = app.alerts["Error Loading Data"]
        XCTAssert(coreDataErrorAlert.waitForExistence(timeout: 10))
    }

    func test_unsupportedAppVersion() {
        app.launchArguments.append("-testUnsupportedVersion")
        app.launch()

        let unsupportedAppAlert = app.alerts["Unsupported App Version"]
        XCTAssert(unsupportedAppAlert.waitForExistence(timeout: 10))
    }

}
