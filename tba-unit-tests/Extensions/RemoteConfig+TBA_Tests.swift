import XCTest
import FirebaseRemoteConfig
@testable import The_Blue_Alliance

// NOTE: These tests will fail locally, since Firebase will pull from production
// These tests will pass on CI, because our Firebase is a dummy setup upstream
class RemoteConfigTBATestCase: XCTestCase {

    var remoteConfig: RemoteConfig!
    var remoteConfigTesting: [String: NSObject] = [
        "current_season": NSNumber(value: 2015),
        "latest_app_version": NSNumber(value: -1),
        "min_app_version": NSNumber(value: -1),
        "max_season": NSNumber(value: 2015),
        "mytba_enabled": NSNumber(value: 1),
        "app_store_id": NSString(string: "tba_testing_id")
    ]

    override func setUp() {
        super.setUp()

        remoteConfig = RemoteConfig.remoteConfig()
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

    func test_myTBAEnabled() {
        XCTAssert(remoteConfig.myTBAEnabled)
    }

    func test_appStoreID() {
        XCTAssertEqual(remoteConfig.appStoreID, "tba_testing_id")
    }

}
