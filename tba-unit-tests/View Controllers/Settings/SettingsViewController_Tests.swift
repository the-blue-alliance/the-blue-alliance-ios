import XCTest
import TBAKit
@testable import The_Blue_Alliance

class SettingsViewControllerTestCase: XCTestCase {

    var mockURLOpener: MockURLOpener!
    var persistentContainer: MockPersistentContainer!

    var settingsViewController: SettingsViewController!

    override func setUp() {
        super.setUp()

        persistentContainer = MockPersistentContainer(name: "Test")
        mockURLOpener = MockURLOpener()

        settingsViewController = SettingsViewController(urlOpener: mockURLOpener,
                                                        persistentContainer: persistentContainer)
    }

    override func tearDown() {
        mockURLOpener = nil
        settingsViewController = nil

        super.tearDown()
    }

    func test_openTBAWebsite() {
        let expectation = XCTestExpectation(description: "open called")
        guard let url = URL(string: InfoURL.website.rawValue) else {
            XCTFail()
            return
        }
        mockURLOpener.mockURL = url
        mockURLOpener.openAssert = expectation

        settingsViewController.openTBAWebsite()

        wait(for: [expectation], timeout: 1.0)
    }

    func test_openTBAGitHub() {
        let expectation = XCTestExpectation(description: "open called")
        guard let url = URL(string: InfoURL.github.rawValue) else {
            XCTFail()
            return
        }
        mockURLOpener.mockURL = url
        mockURLOpener.openAssert = expectation

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
