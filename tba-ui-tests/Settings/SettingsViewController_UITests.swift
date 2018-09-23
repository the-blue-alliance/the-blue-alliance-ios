import XCTest

class SettingsViewController_UITestCase: TBAUITestCase {

    override func setUp() {
        super.setUp()

        let settingsButton = XCUIApplication().tabBars.buttons["Settings"]
        XCTAssert(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()
    }

    func test_openWebiste() {
        let tba = XCUIApplication(bundleIdentifier: "com.the-blue-alliance.the-blue-alliance")
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

        app.tables.cells.staticTexts["The Blue Alliance Website"].tap()
        _ = safari.wait(for: .runningForeground, timeout: 10)
        tba.activate()
        _ = tba.wait(for: .runningForeground, timeout: 10)
    }

    func test_openGitHub() {
        let tba = XCUIApplication(bundleIdentifier: "com.the-blue-alliance.the-blue-alliance")
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

        app.tables.cells.staticTexts["The Blue Alliance for iOS is open source"].tap()
        _ = safari.wait(for: .runningForeground, timeout: 10)
        tba.activate()
        _ = tba.wait(for: .runningForeground, timeout: 10)
    }

    func test_deleteNetworkCache() {
        let tablesQuery = XCUIApplication().tables
        let deleteNetworkCacheStaticText = tablesQuery.cells.staticTexts["Delete network cache"]
        deleteNetworkCacheStaticText.tap()

        let deleteNetworkCacheAlert = XCUIApplication().alerts["Delete Network Cache"]
        deleteNetworkCacheAlert.buttons["Cancel"].tap()
        XCTAssertFalse(deleteNetworkCacheAlert.exists)

        deleteNetworkCacheStaticText.tap()
        deleteNetworkCacheAlert.buttons["Delete"].tap()
        XCTAssertFalse(deleteNetworkCacheAlert.exists)
    }

}
