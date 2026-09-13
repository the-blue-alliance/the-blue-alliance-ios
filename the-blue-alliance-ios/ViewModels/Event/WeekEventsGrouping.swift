import Foundation
import TBAAPI

enum WeekEventsGrouping {

    // Picks a single representative event per week / event-type /
    // offseason-month so the UI can render one row per bucket in the
    // year/week selector. Rows go Preseason → weeks, Championship, and FoC
    // by date → Offseason → Other.
    static func weekEvents(for year: Int, from events: [Event]) -> [Event] {
        let candidates = events.filter { $0.year == year && !$0.isChampionshipDivision }
        let timeline = SeasonTimeline(candidates)
        var seen = Set<String>()
        return
            candidates
            .sorted {
                (timeline.placement(of: $0), $0.section) < (timeline.placement(of: $1), $1.section)
            }
            .filter { seen.insert($0.weekPickerBucket).inserted }
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
