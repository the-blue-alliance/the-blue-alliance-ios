import Foundation

extension TimeZone {
    /// UTC, for pinning `DateFormatter.timeZone` when parsing or rendering
    /// TBA's `yyyy-MM-dd` event dates. Companion to `Calendar.utc`.
    public static let utc: TimeZone = TimeZone(abbreviation: "UTC") ?? .current
}
