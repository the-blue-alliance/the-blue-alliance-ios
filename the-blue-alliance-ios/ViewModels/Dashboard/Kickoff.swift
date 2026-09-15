import Foundation

// Mirrors the server's SeasonHelper.kickoff_datetime_est for when /status doesn't carry
// kickoff_datetime: the first Saturday after Jan 2, at noon Eastern (10:30 before 2021).
nonisolated enum Kickoff {

    static let timeZone = TimeZone(identifier: "America/New_York")!

    static func date(for year: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let jan2 = calendar.date(
            from: DateComponents(
                year: year,
                month: 1,
                day: 2,
                hour: year >= 2021 ? 12 : 10,
                minute: year >= 2021 ? 0 : 30
            )
        )!
        var daysAhead = 7 - calendar.component(.weekday, from: jan2)
        if daysAhead <= 0 {
            daysAhead += 7
        }
        var kickoff = calendar.date(byAdding: .day, value: daysAhead, to: jan2)!
        // 2026 was pushed back a week.
        if year == 2026 {
            kickoff = calendar.date(byAdding: .day, value: 7, to: kickoff)!
        }
        return kickoff
    }

}
