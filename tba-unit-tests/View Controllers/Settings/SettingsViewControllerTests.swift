import FirebaseMessaging
import XCTest
@testable import TBA

class SettingsViewControllerTests: TBATestCase {

    var settingsViewController: SettingsViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        settingsViewController = SettingsViewController(messaging: Messaging.messaging(),
                                                        metadata: ReactNativeMetadata(userDefaults: userDefaults),
                                                        myTBA: myTBA,
                                                        pushService: pushService,
                                                        urlOpener: urlOpener,
                                                        persistentContainer: persistentContainer,
                                                        tbaKit: tbaKit,
                                                        userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: settingsViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        settingsViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        // TODO: Mock bundle and fix snapshot tests
        // verifyLayer(viewControllerTester.window.layer)
    }

    func test_title() {
        XCTAssertEqual(settingsViewController.title, "Settings")
    }

    func test_tabBar() {
        XCTAssertEqual(settingsViewController.tabBarItem.title, "Settings")
    }

    func test_openTBAWebsite() {
        let expectation = XCTestExpectation(description: "open called")
        guard let url = URL(string: InfoURL.website.rawValue) else {
            XCTFail()
            return
        }
        urlOpener.mockURL = url
        urlOpener.openAssert = expectation

        settingsViewController.openTBAWebsite()

        wait(for: [expectation], timeout: 1.0)
    }

    func test_openTBAGitHub() {
        let expectation = XCTestExpectation(description: "open called")
        guard let url = URL(string: InfoURL.github.rawValue) else {
            XCTFail()
            return
        }
        urlOpener.mockURL = url
        urlOpener.openAssert = expectation

        settingsViewController.openGitHub()

        wait(for: [expectation], timeout: 1.0)
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
