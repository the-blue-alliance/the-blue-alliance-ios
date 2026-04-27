import Foundation
import TBAAPI

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

extension EventSection: TableSectionTitleProviding {
    public var headerTitle: String? { title }
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
}

extension Event {
    var section: EventSection {
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
                subOrder: 0,
                title: "\(districtSectionName) District Events"
            )
        case .districtChampionship, .districtChampionshipDivision:
            // DCMP parent + its divisions share one section per district.
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
    public static func sectionAscending(_ a: Event, _ b: Event) -> Bool {
        if a.section != b.section { return a.section < b.section }
        if a.eventType != b.eventType { return a.eventType.rawValue < b.eventType.rawValue }
        let ad = a.startDateParsed ?? .distantFuture
        let bd = b.startDateParsed ?? .distantFuture
        if ad != bd { return ad < bd }
        return a.key < b.key
    }
}
