import Foundation
import TBAUtils

// https://github.com/the-blue-alliance/the-blue-alliance/blob/master/consts/event_type.py
public enum APIEventType: Int, CaseIterable, Sendable {
    case regional = 0
    case district = 1
    case districtChampionship = 2
    case championshipDivision = 3
    case championshipFinals = 4
    case districtChampionshipDivision = 5
    case festivalOfChampions = 6
    case offseason = 99
    case preseason = 100
    case unlabeled = -1
}

extension Event {

    public var eventTypeEnum: APIEventType? {
        APIEventType(rawValue: eventType)
    }

    public var safeShortName: String {
        guard let shortName, !shortName.isEmpty else { return name }
        return shortName
    }

    public var safeNameYear: String {
        name.isEmpty ? key : "\(year) \(name)"
    }

    public var friendlyNameWithYear: String {
        var parts = [String(year)]
        if let shortName, !shortName.isEmpty {
            parts.append(shortName)
            parts.append(eventTypeString.isEmpty ? "Event" : eventTypeString)
        } else {
            parts.append(name)
        }
        return parts.joined(separator: " ")
    }

    public var weekString: String {
        guard let eventTypeEnum else { return "Unknown" }

        if eventTypeEnum == .championshipDivision || eventTypeEnum == .championshipFinals {
            if year >= 2017, let city, !city.isEmpty {
                return "Championship - \(city)"
            }
            return "Championship"
        }

        switch eventTypeEnum {
        case .unlabeled:
            return "Other"
        case .preseason:
            return "Preseason"
        case .offseason:
            return month.map { "\($0) Offseason" } ?? "Offseason"
        case .festivalOfChampions:
            return "Festival of Champions"
        default:
            guard let week else { return "Other" }
            // Special case: 2016's "week 0" was actually week 0.5; all other 2016 weeks are off by one.
            // See http://www.usfirst.org/roboticsprograms/frc/blog-The-Palmetto-Regional
            if year == 2016 {
                return week == 0 ? "Week 0.5" : "Week \(week)"
            }
            return "Week \(week + 1)"
        }
    }

    public var month: String? {
        guard let date = startDateParsed else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.timeZone = .utc
        return formatter.string(from: date)
    }

    public var isChampionshipDivision: Bool { eventTypeEnum == .championshipDivision }
    public var isChampionshipFinals: Bool { eventTypeEnum == .championshipFinals }
    public var isChampionshipEvent: Bool { isChampionshipDivision || isChampionshipFinals }
    public var isDistrictChampionship: Bool { eventTypeEnum == .districtChampionship }
    public var isDistrictChampionshipDivision: Bool {
        eventTypeEnum == .districtChampionshipDivision
    }
    public var isDistrictChampionshipEvent: Bool {
        isDistrictChampionship || isDistrictChampionshipDivision
    }
    public var isFoC: Bool { eventTypeEnum == .festivalOfChampions }
    public var isPreseason: Bool { eventTypeEnum == .preseason }
    public var isOffseason: Bool { eventTypeEnum == .offseason }
    public var isRegional: Bool { eventTypeEnum == .regional }
    public var isUnlabeled: Bool { eventTypeEnum == .unlabeled }

    public var hasWebsite: Bool {
        guard let website else { return false }
        return !website.isEmpty
    }

    // Inclusive end of the event's final UTC day. Prefer this over raw
    // `endDateParsed` for "is the event over?" checks — `endDateParsed` is
    // UTC midnight of the end day, so comparing it directly to a wall-clock
    // `Date()` clips the whole final day for users west of UTC.
    public var endOfEventDay: Date? {
        endDateParsed?.endOfDay(calendar: .utc)
    }

    // Event is currently going on, based on its start and end dates.
    public var isHappeningNow: Bool {
        guard let start = startDateParsed, let end = endOfEventDay else { return false }
        let now = Date()
        return now >= start && now <= end
    }

    // Event is going on now or starts within the next week.
    public var isHappeningThisWeek: Bool {
        guard let start = startDateParsed, let end = endOfEventDay else { return false }
        guard let startOfWeek = Calendar.utc.date(byAdding: .day, value: -7, to: start) else {
            return false
        }
        let now = Date()
        return now >= startOfWeek && now <= end
    }

}

extension Event {

    // Parsed Date form of the API's string date fields. The generated struct
    // stores `startDate` and `endDate` as ISO-ish `yyyy-MM-dd` strings;
    // `TBAAPI.dateFormatter` parses them in UTC so in-memory Date comparisons
    // are consistent regardless of the user's locale.
    public var startDateParsed: Date? { TBAAPI.dateFormatter.date(from: startDate) }
    public var endDateParsed: Date? { TBAAPI.dateFormatter.date(from: endDate) }

    public var locationString: String? {
        let parts = [city, stateProv, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? locationName : parts.joined(separator: ", ")
    }

    public var dateString: String? {
        guard let start = startDateParsed, let end = endDateParsed else { return nil }
        // Dates are UTC-midnight; format and compare year components in UTC so
        // users west of UTC don't see the range shifted back a day.
        let shortFormatter = DateFormatter()
        shortFormatter.dateFormat = "MMM dd"
        shortFormatter.timeZone = .utc

        let longFormatter = DateFormatter()
        longFormatter.dateFormat = "MMM dd, y"
        longFormatter.timeZone = .utc

        if start == end {
            return shortFormatter.string(from: end)
        }
        if Calendar.utc.component(.year, from: start) == Calendar.utc.component(.year, from: end) {
            return "\(shortFormatter.string(from: start)) to \(shortFormatter.string(from: end))"
        }
        return "\(shortFormatter.string(from: start)) to \(longFormatter.string(from: end))"
    }
}
