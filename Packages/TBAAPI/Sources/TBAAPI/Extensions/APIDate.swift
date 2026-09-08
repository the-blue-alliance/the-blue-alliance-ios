import Foundation
import Synchronization

/// Event and webcast dates are calendar days at UTC midnight, so they format in GMT or
/// users west of UTC see the day before. Match times are instants and follow the user.
enum APIDate {

    /// "March"
    static let monthName = Date.FormatStyle(timeZone: .gmt).month(.wide)
    /// "Mar 5"
    static let shortDate = Date.FormatStyle(timeZone: .gmt).month(.abbreviated).day()
    /// "Mar 5, 2026"
    static let shortDateWithYear = Date.FormatStyle(timeZone: .gmt).month(.abbreviated).day().year()
    /// "Sat 9:30 AM", or "Sat 09:30" for a 24-hour clock
    static let weekdayTime = Date.FormatStyle().weekday(.abbreviated).hour().minute()

    // Parsed inside sort comparators over a year of events; a season has ~80 distinct dates.
    private static let style = Date.ISO8601FormatStyle(timeZone: .gmt).year().month().day()
    private static let cache = Mutex<[String: Date]>([:])

    static func parse(_ string: String) -> Date? {
        if let cached = cache.withLock({ $0[string] }) {
            return cached
        }
        guard let date = try? Date(string, strategy: style) else {
            return nil
        }
        cache.withLock { $0[string] = date }
        return date
    }

}
