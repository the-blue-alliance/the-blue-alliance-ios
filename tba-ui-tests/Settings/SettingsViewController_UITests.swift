import XCTest

class SettingsViewController_UITestCase: TBAUITestCase {

    override func setUp() {
        super.setUp()

        let settingsButton = app.tabBars.buttons["Settings"]
        XCTAssert(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()
    }

    func test_showsAppVersion() {
        let appVersionPredicate = NSPredicate(format: "label CONTAINS[c] 'The Blue Alliance for iOS - v'")
        let appVersionTexts = app.tables.staticTexts.containing(appVersionPredicate)
        XCTAssert(appVersionTexts.firstMatch.exists)

        let reactNativeVersionPredicate = NSPredicate(format: "label CONTAINS[c] 'TBA RN -'")
        let reactNativeVersionTexts = app.tables.staticTexts.containing(reactNativeVersionPredicate)
        XCTAssert(reactNativeVersionTexts.firstMatch.exists)
    }

    func test_deleteNetworkCache() {
        let tablesQuery = app.tables
        let deleteNetworkCacheStaticText = tablesQuery.cells.staticTexts["Delete network cache"]
        deleteNetworkCacheStaticText.tap()

        let deleteNetworkCacheAlert = app.alerts["Delete Network Cache"]
        deleteNetworkCacheAlert.buttons["Cancel"].tap()
        XCTAssertFalse(deleteNetworkCacheAlert.exists)

        deleteNetworkCacheStaticText.tap()
        deleteNetworkCacheAlert.buttons["Delete"].tap()
        XCTAssertFalse(deleteNetworkCacheAlert.exists)
    }

}
