import Foundation
import TBAAPI

// Grouping + ordering model for the Week Events screen. sortOrder is
// derived from the TBA `event_type` integer so we don't carry arbitrary
// bucket offsets, and unknown event types fall through gracefully to
// their raw integer position with whatever label the API sent.
public struct EventSection: Hashable, Comparable {
    public let sortOrder: Int
    public let subOrder: Int
    public let title: String

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
        if lhs.subOrder != rhs.subOrder { return lhs.subOrder < rhs.subOrder }
        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }
}

extension APIEventType {
    // Section ordering in the Week view. Mostly the TBA rawValue, with two
    // sentinels whose rawValue doesn't match display intent:
    //   • preseason (100) renders first
    //   • unlabeled (-1) renders last
    var displayOrder: Int {
        switch self {
        case .preseason: return -1
        case .unlabeled: return Int.max
        default: return rawValue
        }
    }
}

extension Event {
    var section: EventSection {
        guard let type = eventTypeEnum else {
            // New TBA event_type we haven't shipped a case for. Sort by the
            // raw integer so it slots between known types, and use the
            // API-provided string as the title so it's at least self-describing.
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
                subOrder: 0,
                title: "\(districtSectionName) District Events"
            )
        case .districtChampionship, .districtChampionshipDivision:
            // Parent + divisions share one section per district, keyed off the
            // parent's displayOrder so both types land on the same sortOrder.
            return .init(
                sortOrder: APIEventType.districtChampionship.displayOrder,
                subOrder: 0,
                title: districtSectionName
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

    // Display name for a district-scoped section; falls back to the uppercased
    // abbreviation (e.g. FIM) if the API didn't send a populated displayName.
    private var districtSectionName: String {
        guard let district else { return "District" }
        return district.displayName.isEmpty
            ? district.abbreviation.uppercased() : district.displayName
    }

    private var championshipSectionLabel: String {
        if year >= 2017, let city, !city.isEmpty { return "Championship - \(city)" }
        return "Championship"
    }

    // Default ordering for event lists within a single year: by section,
    // then by event_type (so DCMP parent 2 sorts before division 5), then
    // by start date, then by key. Callers that mix years should compare
    // year first and fall back to this.
    public static func sectionAscending(_ a: Event, _ b: Event) -> Bool {
        if a.section != b.section { return a.section < b.section }
        if a.eventType != b.eventType { return a.eventType < b.eventType }
        let ad = a.startDateParsed ?? .distantFuture
        let bd = b.startDateParsed ?? .distantFuture
        if ad != bd { return ad < bd }
        return a.key < b.key
    }
}
