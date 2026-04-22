import Foundation
import Testing

@testable import TBAUtils

struct DateTBATests {

    let calendar = Calendar.current

    @Test func year() {
        let date = Calendar.current.date(
            from: DateComponents(year: 2012, month: 2, day: 24)
        )!
        #expect(date.year == 2012)
    }

    @Test func isBetween_inclusive() {
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: DateComponents(hour: -1), to: now)!

        #expect(oneHourAgo.isBetween(date: oneHourAgo, andDate: now))
        #expect(oneHourAgo.isBetween(date: now, andDate: oneHourAgo))
        #expect(now.isBetween(date: now, andDate: oneHourAgo))
        #expect(now.isBetween(date: oneHourAgo, andDate: now))
    }

    @Test func isBetween_true() {
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: DateComponents(hour: -1), to: now)!
        let halfHourAgo = calendar.date(byAdding: DateComponents(minute: -30), to: now)!

        #expect(halfHourAgo.isBetween(date: oneHourAgo, andDate: now))
        #expect(halfHourAgo.isBetween(date: now, andDate: oneHourAgo))
    }

    @Test func isBetween_false() {
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: DateComponents(hour: -1), to: now)!
        let epoch = Date(timeIntervalSince1970: 0)

        #expect(!epoch.isBetween(date: oneHourAgo, andDate: now))
        #expect(!epoch.isBetween(date: now, andDate: oneHourAgo))
    }

    @Test func startOfDay() {
        let calendar = Calendar.current
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        #expect(Date().startOfDay() == today)
    }

    @Test func endOfDay() {
        let calendar = Calendar.current
        let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let tomorrow = calendar.date(byAdding: DateComponents(day: 1), to: today)!
        #expect(
            today.endOfDay() == calendar.date(byAdding: DateComponents(second: -1), to: tomorrow)
        )
    }

    @Test func nextWeekday() {
        let calendar = Calendar.current
        let monday = calendar.date(
            from: DateComponents(weekday: Weekday.Monday.rawValue, weekdayOrdinal: 1)
        )!
        let wednesday = calendar.date(byAdding: DateComponents(day: 2), to: monday)!
        #expect(monday.next(.Wednesday) == wednesday)
    }

    @Test func nextWeekday_exclusive() {
        let monday = Calendar.current.date(from: DateComponents(weekday: 2))!
        #expect(monday.next(.Monday) != monday)
    }
}
