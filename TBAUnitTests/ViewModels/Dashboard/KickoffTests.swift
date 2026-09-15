import Foundation
import Testing

@testable import The_Blue_Alliance

struct KickoffTests {

    private static var eastern: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Kickoff.timeZone
        return calendar
    }

    private static func components(_ date: Date) -> (month: Int, day: Int, hour: Int, minute: Int) {
        let parts = eastern.dateComponents([.month, .day, .hour, .minute], from: date)
        return (parts.month!, parts.day!, parts.hour!, parts.minute!)
    }

    // Real kickoff dates. 2027 is the case where Jan 2 is itself a Saturday.
    @Test(arguments: [
        (2020, 1, 4), (2021, 1, 9), (2024, 1, 6), (2025, 1, 4), (2026, 1, 10), (2027, 1, 9),
    ])
    func matchesTheServerRule(year: Int, month: Int, day: Int) {
        let parts = Self.components(Kickoff.date(for: year))
        #expect(parts.month == month)
        #expect(parts.day == day)
    }

    @Test func startsAtNoonEasternSince2021AndTenThirtyBefore() {
        let recent = Self.components(Kickoff.date(for: 2025))
        #expect(recent.hour == 12 && recent.minute == 0)

        let older = Self.components(Kickoff.date(for: 2020))
        #expect(older.hour == 10 && older.minute == 30)
    }

}
