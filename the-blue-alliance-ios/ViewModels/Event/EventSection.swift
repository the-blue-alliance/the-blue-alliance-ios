import Foundation
import TBAAPI
import TBAUtils

nonisolated struct EventSection: Hashable, Comparable {
    let sortOrder: Int
    let subOrder: Int
    let title: String

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
        if lhs.subOrder != rhs.subOrder { return lhs.subOrder < rhs.subOrder }
        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }
}

extension EventSection: TableSectionTitleProviding {
    var headerTitle: String? { title }
}

extension APIEventType {
    // Mostly the TBA rawValue; preseason (100) and unlabeled (-1) are pushed
    // to the ends so they don't render in the middle of the chronological flow.
    var displayOrder: Int {
        switch self {
        case .preseason: return -1
        case .unlabeled: return Int.max
        default: return rawValue
        }
    }

    // The DCMP parent and CMP finals are played after their divisions, so
    // within a shared section they should sort last.
    var isChampionshipFinalsParent: Bool {
        switch self {
        case .districtChampionship, .championshipFinals: return true
        default: return false
        }
    }
}

// Coarse placement within a season, in display order. Official events sort
// by date inside `.season`, so a week delayed past Championship (2026 Israel,
// weeks 17–19) lands after it instead of next to the other weeks.
nonisolated enum SeasonPhase: Comparable {
    case preseason
    case season
    case offseason
    case other
}

nonisolated struct SeasonPlacement: Comparable {
    let phase: SeasonPhase
    let date: Date

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.phase, lhs.date) < (rhs.phase, rhs.date)
    }
}

// Weekly events are placed at their week's earliest start date rather than
// their own, so sections sharing a week tie and fall back to type order.
nonisolated struct SeasonTimeline {
    private struct Week: Hashable {
        let year: Int
        let week: Int
    }

    private let weekStarts: [Week: Date]

    init(_ events: [Event]) {
        var weekStarts: [Week: Date] = [:]
        for event in events {
            guard let week = event.week, let start = event.startDateParsed else { continue }
            let key = Week(year: event.year, week: week)
            weekStarts[key] = min(weekStarts[key] ?? start, start)
        }
        self.weekStarts = weekStarts
    }

    func placement(of event: Event) -> SeasonPlacement {
        let weekStart = event.week.flatMap { weekStarts[Week(year: event.year, week: $0)] }
        return SeasonPlacement(
            phase: event.seasonPhase,
            date: weekStart ?? event.startDateParsed ?? .distantFuture
        )
    }

    func earliestPlacement(of events: [Event]) -> SeasonPlacement {
        events.map { placement(of: $0) }.min()
            ?? SeasonPlacement(phase: .other, date: .distantFuture)
    }
}

extension Event {
    nonisolated var seasonPhase: SeasonPhase {
        switch eventTypeEnum {
        case .preseason: return .preseason
        case .offseason: return .offseason
        case .unlabeled: return .other
        default: return .season
        }
    }

    var section: EventSection { section(splitDistrictsByWeek: false) }

    // `splitDistrictsByWeek` is for the District tab, where a single district's
    // events span multiple weeks and the view wants one section per week.
    // Other views (Team tab, Year/Week tab) leave it false so district events
    // collapse into one section per district.
    func section(splitDistrictsByWeek: Bool) -> EventSection {
        guard let type = eventTypeEnum else {
            // Forward-compat for new TBA event_types we haven't shipped a case for.
            let label = eventTypeString.isEmpty ? "Unknown Events" : "\(eventTypeString) Events"
            return .init(sortOrder: eventType.rawValue, subOrder: 0, title: label)
        }

        switch type {
        case .preseason:
            return .init(sortOrder: type.displayOrder, subOrder: 0, title: "Preseason Events")
        case .regional:
            return .init(sortOrder: type.displayOrder, subOrder: 0, title: "Regional Events")
        case .district:
            return .init(
                sortOrder: type.displayOrder,
                subOrder: splitDistrictsByWeek ? (week ?? Int.max) : 0,
                title: "\(districtSectionName) District Events"
            )
        case .districtChampionship, .districtChampionshipDivision:
            // DCMP parent + its divisions share one section per district.
            return .init(
                sortOrder: APIEventType.districtChampionship.displayOrder,
                subOrder: 0,
                title: "\(districtSectionName) District Championship"
            )
        case .championshipDivision:
            return .init(
                sortOrder: type.displayOrder,
                subOrder: 0,
                title: "\(championshipSectionLabel) Divisions"
            )
        case .championshipFinals:
            return .init(sortOrder: type.displayOrder, subOrder: 0, title: championshipSectionLabel)
        case .festivalOfChampions:
            return .init(sortOrder: type.displayOrder, subOrder: 0, title: "Festival of Champions")
        case .offseason:
            let monthIdx = startDateParsed.map { Calendar.utc.component(.month, from: $0) } ?? 0
            return .init(
                sortOrder: type.displayOrder,
                subOrder: monthIdx,
                title: "\(weekString) Events"
            )
        case .unlabeled:
            return .init(sortOrder: type.displayOrder, subOrder: 0, title: "Unknown Events")
        }
    }

    private var districtSectionName: String {
        guard let district else { return "District" }
        return district.displayName.isEmpty
            ? district.abbreviation.uppercased() : district.displayName
    }

    private var championshipSectionLabel: String {
        if year >= 2017, let city, !city.isEmpty { return "Championship - \(city)" }
        return "Championship"
    }

    // Within-year ordering. Callers that mix years should compare year first.
    static func sectionAscending(_ a: Event, _ b: Event) -> Bool {
        if a.section != b.section { return a.section < b.section }
        if a.eventType != b.eventType {
            let aParent = a.eventTypeEnum?.isChampionshipFinalsParent ?? false
            let bParent = b.eventTypeEnum?.isChampionshipFinalsParent ?? false
            if aParent != bParent { return !aParent }
            return a.eventType.rawValue < b.eventType.rawValue
        }
        let ad = a.startDateParsed ?? .distantFuture
        let bd = b.startDateParsed ?? .distantFuture
        if ad != bd { return ad < bd }
        return a.key < b.key
    }

    static func groupedBySection(
        _ events: [Event],
        splitDistrictsByWeek: Bool = false
    ) -> [(section: EventSection, events: [Event])] {
        let timeline = SeasonTimeline(events)
        return Dictionary(grouping: events) {
            $0.section(splitDistrictsByWeek: splitDistrictsByWeek)
        }
        .sorted {
            (timeline.earliestPlacement(of: $0.value), $0.key)
                < (timeline.earliestPlacement(of: $1.value), $1.key)
        }
        .map { (section: $0.key, events: $0.value.sorted(by: sectionAscending)) }
    }
}
