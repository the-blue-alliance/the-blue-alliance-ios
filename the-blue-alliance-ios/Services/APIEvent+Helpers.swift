import Foundation
import TBAAPI

// Conveniences on the TBAAPI-generated `Components.Schemas.Event` that mirror
// the ones previously defined on the Core Data `Event` managed-object
// subclass in TBAData. Kept here (app target) so `Components.Schemas.Event`
// stays a pure generated type and we can delete TBAData without touching
// these helpers. Semantics match the originals — see
// `Packages/TBAData/Sources/TBAData/Event/Event.swift` for cross-checks.

// https://github.com/the-blue-alliance/the-blue-alliance/blob/master/consts/event_type.py
enum APIEventType: Int {
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

extension Components.Schemas.Event {

    var eventTypeEnum: APIEventType? {
        APIEventType(rawValue: eventType)
    }

    var safeShortName: String {
        guard let shortName, !shortName.isEmpty else { return name }
        return shortName
    }

    var safeNameYear: String {
        name.isEmpty ? key : "\(year) \(name)"
    }

    var friendlyNameWithYear: String {
        var parts = [String(year)]
        if let shortName {
            parts.append(shortName)
            parts.append(eventTypeString.isEmpty ? "Event" : eventTypeString)
        } else {
            parts.append(name)
        }
        return parts.joined(separator: " ")
    }

    var weekString: String {
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

    var month: String? {
        guard let date = startDateParsed else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }

    var isChampionshipDivision: Bool { eventTypeEnum == .championshipDivision }
    var isChampionshipFinals: Bool { eventTypeEnum == .championshipFinals }
    var isChampionshipEvent: Bool { isChampionshipDivision || isChampionshipFinals }
    var isDistrictChampionship: Bool { eventTypeEnum == .districtChampionship }
    var isDistrictChampionshipDivision: Bool { eventTypeEnum == .districtChampionshipDivision }
    var isDistrictChampionshipEvent: Bool { isDistrictChampionship || isDistrictChampionshipDivision }
    var isFoC: Bool { eventTypeEnum == .festivalOfChampions }
    var isPreseason: Bool { eventTypeEnum == .preseason }
    var isOffseason: Bool { eventTypeEnum == .offseason }
    var isRegional: Bool { eventTypeEnum == .regional }
    var isUnlabeled: Bool { eventTypeEnum == .unlabeled }

    // Sort key used in place of the Core Data `hybridType` attribute — groups
    // events by their "conceptual bucket" within a season so the weekly
    // section headers stack in a sensible order.
    var hybridTypeSortKey: String {
        if isDistrictChampionshipEvent {
            if eventTypeEnum == .districtChampionshipDivision, let abbrev = district?.abbreviation {
                return "\(APIEventType.districtChampionship.rawValue)..\(abbrev).dcmpd"
            }
            return "\(eventType)"
        }
        if let district, !isDistrictChampionshipEvent {
            return "\(eventType).\(district.abbreviation)"
        }
        if eventTypeEnum == .offseason, let date = startDateParsed {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMM"
            return "\(eventType).\(formatter.string(from: date))"
        }
        return "\(eventType)"
    }
}

extension Components.Schemas.Event {

    // Parsed Date form of the API's string date fields. The generated struct
    // stores `startDate` and `endDate` as ISO-ish `yyyy-MM-dd` strings; these
    // use a matching formatter in UTC so our in-memory Date comparisons are
    // consistent regardless of the user's locale.
    var startDateParsed: Date? { APIEventDateFormatter.shared.date(from: startDate) }
    var endDateParsed: Date? { APIEventDateFormatter.shared.date(from: endDate) }

    // Ported from TBAProtocols.Locatable (same formula as the old Event entity).
    var locationString: String? {
        let parts = [city, stateProv, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? locationName : parts.joined(separator: ", ")
    }

    // Ported from TBAProtocols.Dateable.
    var dateString: String? {
        guard let start = startDateParsed, let end = endDateParsed else { return nil }
        let calendar = Calendar.current

        let shortFormatter = DateFormatter()
        shortFormatter.dateFormat = "MMM dd"

        let longFormatter = DateFormatter()
        longFormatter.dateFormat = "MMM dd, y"

        if start == end {
            return shortFormatter.string(from: end)
        }
        if calendar.component(.year, from: start) == calendar.component(.year, from: end) {
            return "\(shortFormatter.string(from: start)) to \(shortFormatter.string(from: end))"
        }
        return "\(shortFormatter.string(from: start)) to \(longFormatter.string(from: end))"
    }
}

private enum APIEventDateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
