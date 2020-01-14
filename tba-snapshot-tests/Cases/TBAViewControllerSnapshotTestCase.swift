import Foundation
import MyTBAKitTesting
import TBAKitTesting
import XCTest
@testable import The_Blue_Alliance

class TBAViewControllerSnapshotTestCase: TBASnapshotTestCase {

    // TODO: DRY this out with the unit tests
    var testBundle: Bundle!
    var myTBA: MockMyTBA!
    var tbaKit: MockTBAKit!
    var userDefaults: UserDefaults!
    var urlOpener: MockURLOpener!
    var statusService: StatusService!

    override func setUp() {
        super.setUp()

        testBundle = Bundle(for: type(of: self))
        userDefaults = UserDefaults(suiteName: "TBATests")
        myTBA = MockMyTBA()

        tbaKit = MockTBAKit(userDefaults: userDefaults)
        tbaKit.interceptRequests()

        urlOpener = MockURLOpener()
        statusService = StatusService(bundle: testBundle, persistentContainer: coreDataTestFixture.persistentContainer, retryService: RetryService(), tbaKit: tbaKit)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "TBATests")
        urlOpener = nil

        super.tearDown()
    }

    func verifyViewController<T>(_ vc: TBAViewControllerTester<T>, identifier: String = "") {
        verifyLayer(vc.window.layer, identifier: identifier)
    }

}

class MockURLOpener: URLOpener {

    func canOpenURL(_ url: URL) -> Bool {
        return false
    }

    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        // pass
    }

}

/*
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
*/
