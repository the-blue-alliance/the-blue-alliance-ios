import XCTest
@testable import The_Blue_Alliance

internal struct KDate {
    static let secondsInAnHour = 3600.0
}

class Date_TBA_Tests: XCTestCase {

    func test_isBetween_true() {
        let oneHourAgo = Date(timeIntervalSinceNow: (-1 * KDate.secondsInAnHour))
        let now = Date()
        let halfHourAgo = Date(timeIntervalSinceNow: (-0.5 * KDate.secondsInAnHour))

        XCTAssert(halfHourAgo.isBetween(date: oneHourAgo, andDate: now))
        XCTAssert(halfHourAgo.isBetween(date: now, andDate: oneHourAgo))
    }

    func test_isBetween_false() {
        let oneHourAgo = Date(timeIntervalSinceNow: (-1 * KDate.secondsInAnHour))
        let now = Date()
        let epoch = Date(timeIntervalSince1970: 0)

        XCTAssertFalse(epoch.isBetween(date: oneHourAgo, andDate: now))
        XCTAssertFalse(epoch.isBetween(date: now, andDate: oneHourAgo))
    }

}
