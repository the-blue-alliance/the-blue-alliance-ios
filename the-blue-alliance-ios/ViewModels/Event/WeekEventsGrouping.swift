import Foundation
import TBAAPI

enum WeekEventsGrouping {

    // Picks a single representative event per week / event-type /
    // offseason-month so the UI can render one row per bucket in the
    // year/week selector.
    static func weekEvents(for year: Int, from events: [Event]) -> [Event] {
        let candidates = events.filter { $0.year == year && !$0.isChampionshipDivision }
        var seen = Set<String>()
        return candidates
            .sorted(by: pickerOrder)
            .filter { seen.insert($0.weekPickerBucket).inserted }
    }

    // Picker display order: Preseason → Week N → Championship → FoC → Offseason → Unlabeled.
    // Different weeks of the same event type need to sort by week, so `week` is part of the key.
    private static func pickerOrder(_ a: Event, _ b: Event) -> Bool {
        let lhs = (a.section.sortOrder, a.week ?? Int.max, a.section.subOrder, a.section.title)
        let rhs = (b.section.sortOrder, b.week ?? Int.max, b.section.subOrder, b.section.title)
        if lhs.0 != rhs.0 { return lhs.0 < rhs.0 }
        if lhs.1 != rhs.1 { return lhs.1 < rhs.1 }
        if lhs.2 != rhs.2 { return lhs.2 < rhs.2 }
        return lhs.3.localizedCaseInsensitiveCompare(rhs.3) == .orderedAscending
    }
}

private extension Event {
    // Week-picker dedup bucket: one row per week, per CMP finals (by key),
    // per offseason month, or per unique non-weekly event type.
    var weekPickerBucket: String {
        if let week { return "week-\(week)" }
        guard let type = eventTypeEnum else { return "unknown-\(eventType)" }
        switch type {
        case .championshipFinals: return "cmp-finals-\(key)"
        case .offseason: return month.map { "offseason-\($0)" } ?? "offseason"
        default: return "type-\(eventType)"
        }
    }
}
