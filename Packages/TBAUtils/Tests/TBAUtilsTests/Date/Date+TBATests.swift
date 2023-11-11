import TBAUtils
import XCTest

class DateTBATestCase: XCTestCase {

    let calendar: Calendar = Calendar.current

    func test_year() {
        var components = DateComponents()
        components.month = 2
        components.day = 24
        components.year = 2012

        let date = Calendar.current.date(from: components)!
        XCTAssertEqual(date.year, 2012)
    }

    func test_isBetween_inclusive() {
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: DateComponents(hour: -1), to: now)!

        XCTAssert(oneHourAgo.isBetween(date: oneHourAgo, andDate: now))
        XCTAssert(oneHourAgo.isBetween(date: now, andDate: oneHourAgo))
        XCTAssert(now.isBetween(date: now, andDate: oneHourAgo))
        XCTAssert(now.isBetween(date: oneHourAgo, andDate: now))
    }

    func test_isBetween_true() {
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: DateComponents(hour: -1), to: now)!
        let halfHourAgo = calendar.date(byAdding: DateComponents(minute: -30), to: now)!

        XCTAssert(halfHourAgo.isBetween(date: oneHourAgo, andDate: now))
        XCTAssert(halfHourAgo.isBetween(date: now, andDate: oneHourAgo))
    }

    func test_isBetween_false() {
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: DateComponents(hour: -1), to: now)!
        let epoch = Date(timeIntervalSince1970: 0)

        XCTAssertFalse(epoch.isBetween(date: oneHourAgo, andDate: now))
        XCTAssertFalse(epoch.isBetween(date: now, andDate: oneHourAgo))
    }

    func test_startOfDay() {
        let calendar = Calendar.current
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        XCTAssertEqual(Date().startOfDay(), today)
    }

    func test_endOfDay() {
        let calendar = Calendar.current
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let tomorrow = calendar.date(byAdding: DateComponents(day: 1), to: today)!
        XCTAssertEqual(today.endOfDay(), calendar.date(byAdding: DateComponents(second: -1), to: tomorrow))
    }

    func test_next() {
        let calendar = Calendar.current
        let monday = calendar.date(from: DateComponents(weekday: Weekday.Monday.rawValue, weekdayOrdinal: 1))!
        let wednesday = calendar.date(byAdding: DateComponents(day: 2), to: monday)!
        XCTAssertEqual(monday.next(.Wednesday), wednesday)
    }

    func test_next_exclusive() {
        let monday = Calendar.current.date(from: DateComponents(weekday: 2))!
        XCTAssertNotEqual(monday.next(.Monday), monday)
    }

}
