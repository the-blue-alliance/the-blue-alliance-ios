import Foundation
import TBAAPI

enum WeekEventsGrouping {

    // Picks a single representative event per week / event-type / offseason-month
    // so the UI can render one row per bucket in the year/week selector.
    static func weekEvents(for year: Int, from events: [Event]) -> [Event] {
        let candidates = events
            .filter { $0.year == year }
            // Exclude CMP divisions — we keep those out of the week picker.
            .filter { !$0.isChampionshipDivision }
            .sorted { lhs, rhs in
                if lhs.week != rhs.week {
                    return (lhs.week ?? Int.max) < (rhs.week ?? Int.max)
                }
                if lhs.eventType != rhs.eventType {
                    return lhs.eventType < rhs.eventType
                }
                guard let l = lhs.endDateParsed, let r = rhs.endDateParsed else { return false }
                return l < r
            }

        var handledWeeks: Set<Int> = []
        var handledTypes: Set<APIEventType> = []
        var handledOffseasonMonths: Set<String> = []
        var handledUnknown = false

        var picked: [Event] = []
        for event in candidates {
            guard let type = event.eventTypeEnum else {
                // Unknown event type — keep one representative.
                if handledUnknown { continue }
                handledUnknown = true
                picked.append(event)
                continue
            }

            if let week = event.week {
                if handledWeeks.insert(week).inserted {
                    picked.append(event)
                }
            } else if type == .championshipFinals {
                // All CMP finals fields are kept individually.
                picked.append(event)
            } else if type == .offseason {
                guard let month = event.month else { continue }
                if handledOffseasonMonths.insert(month).inserted {
                    picked.append(event)
                }
            } else {
                // Preseason / unlabeled / others — one per type.
                if handledTypes.insert(type).inserted {
                    picked.append(event)
                }
            }
        }

        return picked.sorted()
    }
}

// MARK: - Comparable port

extension Event: Comparable {

    // Port of TBAData.Event's `Comparable` ordering:
    //   Preseason, Week 1, Week 2, …, Week 7, CMP divisions, CMP finals, FoC, Offseason, Unlabeled
    public static func < (lhs: Event, rhs: Event) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }

        guard let lhsType = lhs.eventTypeEnum, let rhsType = rhs.eventTypeEnum else {
            return lhs.key < rhs.key
        }

        // Preseason (eventType 100) — highest raw value but renders first.
        if lhs.isPreseason || rhs.isPreseason {
            if lhs.isPreseason && rhs.isPreseason, let l = lhs.startDateParsed, let r = rhs.startDateParsed {
                return l < r
            }
            return lhsType.rawValue > rhsType.rawValue
        }
        // Unlabeled — always last.
        if lhs.isUnlabeled || rhs.isUnlabeled {
            if lhs.isUnlabeled && rhs.isUnlabeled, let l = lhs.startDateParsed, let r = rhs.startDateParsed {
                return l < r
            }
            return lhsType.rawValue > rhsType.rawValue
        }
        // Offseason — after everything besides unlabeled.
        if lhs.isOffseason || rhs.isOffseason {
            if lhs.isOffseason && rhs.isOffseason, let l = lhs.startDateParsed, let r = rhs.startDateParsed {
                return l < r
            }
            return lhsType.rawValue < rhsType.rawValue
        }
        // Festival of Champions — after CMP.
        if lhs.isFoC || rhs.isFoC {
            if lhs.isFoC && rhs.isFoC, let l = lhs.startDateParsed, let r = rhs.startDateParsed {
                return l < r
            }
            return lhsType.rawValue < rhsType.rawValue
        }
        // CMP finals.
        if lhs.isChampionshipFinals || rhs.isChampionshipFinals {
            if lhs.isChampionshipFinals && rhs.isChampionshipFinals, let l = lhs.startDateParsed, let r = rhs.startDateParsed {
                return l < r
            }
            if lhs.isDistrictChampionshipDivision || rhs.isDistrictChampionshipDivision {
                return lhsType.rawValue > rhsType.rawValue
            }
            return lhsType.rawValue < rhsType.rawValue
        }
        // CMP divisions.
        if lhs.isChampionshipDivision || rhs.isChampionshipDivision {
            if lhs.isChampionshipDivision && rhs.isChampionshipDivision, let l = lhs.startDateParsed, let r = rhs.startDateParsed {
                return l < r
            }
            if lhs.isDistrictChampionshipDivision || rhs.isDistrictChampionshipDivision {
                return lhsType.rawValue > rhsType.rawValue
            }
            return lhsType.rawValue < rhsType.rawValue
        }
        // Everything else — districts, regionals, DCMPs, DCMP divisions — sorted by week.
        // Within a week: Regional < District < DCMP Division < DCMP (DCMP div is a higher raw value,
        // so flip when both sides are district-CMP).
        if let lWeek = lhs.week, let rWeek = rhs.week {
            if lWeek == rWeek {
                if lhs.isDistrictChampionshipEvent && rhs.isDistrictChampionshipEvent {
                    if let l = lhs.startDateParsed, let r = rhs.startDateParsed { return l < r }
                    return lhsType.rawValue > rhsType.rawValue
                }
                if let l = lhs.startDateParsed, let r = rhs.startDateParsed { return l < r }
                return lhsType.rawValue < rhsType.rawValue
            }
            return lWeek < rWeek
        }
        return false
    }
}
