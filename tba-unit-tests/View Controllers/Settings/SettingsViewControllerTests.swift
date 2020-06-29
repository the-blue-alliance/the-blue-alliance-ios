import XCTest
@testable import The_Blue_Alliance

class SettingsViewControllerTests: TBATestCase {

    var settingsViewController: SettingsViewController!

    override func setUp() {
        super.setUp()

        settingsViewController = SettingsViewController(fcmTokenProvider: fcmTokenProvider,
                                                        myTBA: myTBA,
                                                        pushService: pushService,
                                                        searchService: searchService,
                                                        urlOpener: urlOpener,
                                                        dependencies: dependencies)
    }

    override func tearDown() {
        settingsViewController = nil

        super.tearDown()
    }

    func test_title() {
        XCTAssertEqual(settingsViewController.title, "Settings")
    }

    func test_tabBar() {
        XCTAssertEqual(settingsViewController.tabBarItem.title, "Settings")
    }

}

class MockURLOpener: URLOpener {

    var mockCanOpenURL: Bool?
    var mockURL: URL?
    var openAssert: XCTestExpectation?

    func canOpenURL(_ url: URL) -> Bool {
        return mockCanOpenURL ?? true
    }

    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        XCTAssertEqual(mockURL!, url)

        openAssert?.fulfill()

        if let completion = completion {
            completion(true)
        }
    }

}
