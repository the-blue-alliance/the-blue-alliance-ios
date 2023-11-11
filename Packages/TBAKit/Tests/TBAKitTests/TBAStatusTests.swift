import TBAKit
import XCTest

class TBAStatusTests: TBAKitTestCase {

    func test_status() {
        let ex = expectation(description: "status")

        let task = kit.fetchStatus { (result, notModified) in
            let status = try! result.get()!
            XCTAssertFalse(notModified)

            // Android Info
            XCTAssertNotNil(status.android)
            XCTAssertNotNil(status.android.latestAppVersion)
            XCTAssertNotNil(status.android.minAppVersion)

            // iOS Info
            XCTAssertNotNil(status.ios)
            XCTAssertNotNil(status.ios.latestAppVersion)
            XCTAssertNotNil(status.ios.minAppVersion)

            XCTAssertNotNil(status.currentSeason)
            XCTAssertNotNil(status.downEvents)
            XCTAssertNotNil(status.datafeedDown)
            XCTAssertNotNil(status.maxSeason)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func test_appInfo_json() {
        var json: [String: Any] = [:]

        // No values - nil
        XCTAssertNil(TBAAppInfo(json: json))

        json["latest_app_version"] = [:]
        XCTAssertNil(TBAAppInfo(json: json))

        json["latest_app_version"] = 2
        XCTAssertNil(TBAAppInfo(json: json))

        json["min_app_version"] = 1
        XCTAssertNotNil(TBAAppInfo(json: json))
    }

    func test_appInfo_init() {
        let appInfo = TBAAppInfo(latestAppVersion: 2, minAppVersion: 1)
        XCTAssertEqual(appInfo.latestAppVersion, 2)
        XCTAssertEqual(appInfo.minAppVersion, 1)
    }

    func test_status_json() {
        var json: [String: Any] = [:]

        // No values - nil
        XCTAssertNil(TBAStatus(json: json))

        json["android"] = [:]
        XCTAssertNil(TBAStatus(json: json))

        json["android"] = ["latest_app_version": 2, "min_app_version": 1]
        XCTAssertNil(TBAStatus(json: json))

        json["ios"] = [:]
        XCTAssertNil(TBAStatus(json: json))

        json["ios"] = ["latest_app_version": 2, "min_app_version": 1]
        XCTAssertNil(TBAStatus(json: json))

        json["current_season"] = 2018
        XCTAssertNil(TBAStatus(json: json))

        json["down_events"] = []
        XCTAssertNil(TBAStatus(json: json))

        json["is_datafeed_down"] = true
        XCTAssertNil(TBAStatus(json: json))

        json["max_season"] = 2019
        XCTAssertNotNil(TBAStatus(json: json))
    }

    func test_status_init() {
        let appInfo = TBAAppInfo(latestAppVersion: 2, minAppVersion: 1)
        let status = TBAStatus(android: appInfo,
                               ios: appInfo,
                               currentSeason: 2018,
                               downEvents: ["2018miket"],
                               datafeedDown: true,
                               maxSeason: 2019)

        XCTAssertEqual(status.android, appInfo)
        XCTAssertEqual(status.ios, appInfo)
        XCTAssertEqual(status.currentSeason, 2018)
        XCTAssertEqual(status.downEvents, ["2018miket"])
        XCTAssertEqual(status.datafeedDown, true)
        XCTAssertEqual(status.maxSeason, 2019)
    }

}
