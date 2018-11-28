import XCTest
@testable import The_Blue_Alliance

class RemoteConfigTBATestCase: XCTestCase {

    var remoteConfig: MockRemoteConfig!
    var remoteConfigTesting: [String: NSObject] = [
        "current_season": NSNumber(value: 2015),
        "ios_latest_app_version": NSNumber(value: -1),
        "ios_min_app_version": NSNumber(value: -1),
        "max_season": NSNumber(value: 2015),
        "app_store_id": NSString(string: "tba_testing_id")
    ]

    override func setUp() {
        super.setUp()

        remoteConfig = MockRemoteConfig()
        remoteConfig.setDefaults(remoteConfigTesting)
    }

    override func tearDown() {
        remoteConfig = nil

        super.tearDown()
    }

    func test_currentSeason() {
        XCTAssertEqual(remoteConfig.currentSeason, 2015)
    }

    func test_latestAppVersion() {
        XCTAssertEqual(remoteConfig.latestAppVersion, -1)
    }

    func test_minimumAppVersion() {
        XCTAssertEqual(remoteConfig.minimumAppVersion, -1)
    }

    func test_maxSeason() {
        XCTAssertEqual(remoteConfig.maxSeason, 2015)
    }

    func test_appStoreID() {
        XCTAssertEqual(remoteConfig.appStoreID, "tba_testing_id")
    }

}
