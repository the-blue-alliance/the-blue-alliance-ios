//
//  EventWeek.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 5/3/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI

/**
 EventWeek represents the Week for the Week selector. It groups events by week,
 Preseasons, Offseasons by month, CMP events by CMP, and otherwise events of the
 same type together.
 */
public enum EventWeek: Hashable {
    case eventType(Event.EventType, String) // event_type, event_type_string
    // Note: Represented as a Double because 2016 has a Week 0.5 event
    case week(Double, String) // This is the 1-indexed Week number, week_string
    // Note: index will be empty in the case of getting an Event.eventWeek
    // The index will come back when getting [Event].eventsByWeek()
    // Otherwise, use Event.eventWeek(cmpIndex:) if the index is known
    case cmp(EventKey, Int?, String?) // (event_code, index, city)
    case offseason(Int) // month, 1-12
    case other

    public var description: String {
        switch self {
        case .eventType(_, let eventTypeString):
            return eventTypeString
        case .week(_, let weekString):
            return weekString
        case .cmp(_, let index, let city):
            if let _ = index, let city {
                return "FIRST Championship - \(city)"
            } else {
                return "FIRST Championship"
            }
        case .offseason(let month):
            let monthSymbol = Calendar.current.standaloneMonthSymbols[month - 1]
            return "\(monthSymbol) Offseason"
        case .other:
            return "Other"
        }
    }
}

extension EventWeek: Comparable {
    public static func <(lhs: EventWeek, rhs: EventWeek) -> Bool {
        switch lhs {
        case .other:
            return false
        case .offseason(let lhsMonth) where lhsMonth == 1:
            // Weirdly, float January offseasons to the top
            // Noting: This is probably wrong, since any January offseason would
            // be happening in the ~3-7 days before Kickoff, so technically these events
            // would be previous seson events. But that's not how we would return them from the API.
            return true
        case .eventType(.preseason, _):
            switch rhs {
            case .offseason(let rhsMonth) where rhsMonth == 1:
                return false
            default:
                return true
            }
        case .eventType(let lhsEventType, _):
            switch rhs {
            case .eventType(let rhsEventType, _):
                return lhsEventType < rhsEventType
            case .offseason(_):
                return true
            default:
                return false
            }
        case .week(let lhsWeek, _):
            switch rhs {
            case .offseason(let rhsMonth) where rhsMonth == 1:
                return false
            case .eventType(.preseason, _):
                return false
            case .week(let rhsWeek, _):
                return lhsWeek < rhsWeek
            default:
                return true
            }
        case .cmp(_, let lhsIndex, _):
            switch rhs {
            case .cmp(_, let rhsIndex, _):
                if let lhsIndex, let rhsIndex {
                    return lhsIndex < rhsIndex
                }
                return false
            case .eventType(.festivalOfChampions, _), .offseason(_), .other:
                return true
            default:
                return false
            }
        case .offseason(let lhsMonth):
            switch rhs {
            case .offseason(let rhsMonth):
                return lhsMonth < rhsMonth
            case .other:
                return true
            default:
                return false
            }
        }
    }
}

extension Event {
    public var eventWeek: EventWeek? {
        if let week = week {
            /**
             * Special cases for 2016:
             * Week 1 is actually Week 0.5, eveything else is one less
             * See http://www.usfirst.org/roboticsprograms/frc/blog-The-Palmetto-Regional
             */
            if year == 2016, week == 0 {
                return .week(0.5, weekString)
            }
            return .week(Double(week + 1), weekString)
        } else if isChampionshipEvent {
            return .cmp(parentEventKey ?? key, nil, city)
        } else if isOffseason {
            return .offseason(Calendar.current.component(.month, from: startDate))
        }
        guard let eventType = Event.EventType(rawValue: eventType) else {
            return nil
        }
        return .eventType(eventType, eventTypeString)
    }

    internal func eventWeek(cmpIndex: Int) -> EventWeek? {
        let eventWeek = eventWeek
        switch eventWeek {
        case .cmp(let key, let index, let city) where index == nil:
            return .cmp(key, cmpIndex, city)
        default:
            return eventWeek
        }
    }
}
