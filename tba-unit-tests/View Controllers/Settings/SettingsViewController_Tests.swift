import XCTest
@testable import The_Blue_Alliance

class SettingsViewControllerTestCase: TBATestCase {

    var settingsViewController: SettingsViewController!

    override func setUp() {
        super.setUp()

        settingsViewController = SettingsViewController(urlOpener: urlOpener,
                                                        metadata: ReactNativeMetadata(userDefaults: userDefaults),
                                                        persistentContainer: persistentContainer,
                                                        tbaKit: tbaKit,
                                                        userDefaults: userDefaults)
    }

    override func tearDown() {
        settingsViewController = nil

        super.tearDown()
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
