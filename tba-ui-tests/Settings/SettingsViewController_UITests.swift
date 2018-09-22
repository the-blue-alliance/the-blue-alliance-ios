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

    func test_deleteAppData() {
        let tablesQuery = XCUIApplication().tables
        let deleteAppDataStaticText = tablesQuery.cells.staticTexts["Delete app data"]
        deleteAppDataStaticText.tap()

        let deleteAppDataAlert = XCUIApplication().alerts["Delete App Data"]
        deleteAppDataAlert.buttons["Cancel"].tap()
        XCTAssertFalse(deleteAppDataAlert.exists)

        deleteAppDataStaticText.tap()
        deleteAppDataAlert.buttons["Delete"].tap()
        XCTAssertFalse(deleteAppDataAlert.exists)
    }

}
