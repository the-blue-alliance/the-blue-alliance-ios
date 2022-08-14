import XCTest
import TBAKit

final class TBAKitStatusTests: TBAKitTestCase {

    func test_status() async throws {
        let status = try await kit.status()

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
    }

}
