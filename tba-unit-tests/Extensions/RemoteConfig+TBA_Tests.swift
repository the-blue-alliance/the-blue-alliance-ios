import XCTest
import FirebaseRemoteConfig
@testable import The_Blue_Alliance

class RemoteConfigTBATestCase: XCTestCase {

    var remoteConfig: RemoteConfig!
    var remoteConfigTesting: [String: NSObject] = [
        "current_season": NSNumber(value: 2015),
        "latest_app_version": NSNumber(value: -1),
        "min_app_version": NSNumber(value: -1),
        "max_season": NSNumber(value: 2015)
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

}
