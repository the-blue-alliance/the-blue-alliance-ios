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

extension Event: @retroactive Comparable {

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
        // Everything else — districts, regionals, DCMPs, DCMP divisions — has a
        // week number. Order first by week, then by section within a week, then
        // by event within a section.
        if let lWeek = lhs.week, let rWeek = rhs.week {
            // Different weeks: earlier week comes first.
            if lWeek == rWeek {
                // Same week. Group events into sections using hybridTypeSortKey so
                // the Week view lays out as Regional → District(name) →
                // DCMP/Divisions(name). Lexicographic ordering of the key drives
                // the section order.
                let lKey = lhs.hybridTypeSortKey
                let rKey = rhs.hybridTypeSortKey
                if lKey == rKey {
                    // Same section. DCMP parents (type 2) and DCMP divisions
                    // (type 5) share a section per district — within it, the
                    // parent sorts first so it renders at the top of the
                    // "{District} District Championship Divisions" list.
                    if lhs.eventType == rhs.eventType {
                        // Same section, same type. Break the tie by start date,
                        // then by key, so the sort is deterministic across reloads.
                        if let l = lhs.startDateParsed, let r = rhs.startDateParsed, l != r {
                            return l < r
                        }
                        return lhs.key < rhs.key
                    }
                    return lhs.eventType < rhs.eventType
                }
                return lKey < rKey
            }
            return lWeek < rWeek
        }
        return false
    }
}
