//
//  Event+EventWeek.swift
//  TBA
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
    case cmp(Int?, String?) // (index, city)
    case offseason(Int) // start_date.month 1-12
    case other

    public var description: String {
        switch self {
        case let .eventType(_, eventTypeString):
            return eventTypeString
        case let .week(_, weekString):
            return weekString
        case let .cmp(_, city):
            if let city {
                return "FIRST Championship - \(city)"
            } else {
                return "FIRST Championship"
            }
        case let .offseason(month):
            let monthSymbol = Calendar.current.standaloneMonthSymbols[month - 1]
            return "\(monthSymbol) Offseason"
        case .other:
            return "Other"
        }
    }
}

extension EventWeek: Comparable {
    public static func < (lhs: EventWeek, rhs: EventWeek) -> Bool {
        // First, compare by primary sort order
        let lhsPrimary = lhs.primarySortOrder
        let rhsPrimary = rhs.primarySortOrder

        if lhsPrimary != rhsPrimary {
            return lhsPrimary < rhsPrimary
        }

        // Primary sort orders are equal, now use secondary sorting
        switch (lhs, rhs) {
        case let (.eventType(lhsType, _), .eventType(rhsType, _)):
            // Sort event types by their natural order
            return lhsType < rhsType

        case let (.week(lhsWeek, _), .week(rhsWeek, _)):
            // Sort weeks by week number
            return lhsWeek < rhsWeek

        case let (.cmp(lhsIndex, _), .cmp(rhsIndex, _)):
            // Sort CMP events by index (the order they occur in)
            // Nil indexes sort before non-nil indexes
            switch (lhsIndex, rhsIndex) {
            case (nil, nil):
                return false
            case (nil, _):
                return true
            case (_, nil):
                return false
            case let (lhs?, rhs?):
                return lhs < rhs
            }

        case let (.offseason(lhsMonth), .offseason(rhsMonth)):
            // Sort offseason events by month, with January coming last
            // Treat January (1) as 13 for sorting purposes
            let lhsSortMonth = lhsMonth == 1 ? 13 : lhsMonth
            let rhsSortMonth = rhsMonth == 1 ? 13 : rhsMonth
            return lhsSortMonth < rhsSortMonth

        default:
            // All other cases are equal at this level
            return false
        }
    }

    /// Returns the primary sort order for the event week
    /// Sort order: 1-Preseason, 2-Week, 3-EventType, 4-CMP, 5-FOC, 6-Offseason, 7-Other
    private var primarySortOrder: Int {
        switch self {
        case .eventType(.preseason, _):
            1
        case .eventType(.festivalOfChampions, _):
            5
        case .week:
            2
        case .eventType:
            3
        case .cmp:
            4
        case .offseason:
            6
        case .other:
            7
        }
    }
}

public extension Event {
    var eventWeek: EventWeek? {
        if let week, let weekString {
            /**
             * Special cases for 2016:
             * Week 1 is actually Week 0.5, eveything else is one less
             * Palmetto Regional
             * https://www.thebluealliance.com/event/2016scmb
             */
            if year == 2016, week == 0 {
                return .week(0.5, weekString)
            }
            return .week(Double(week + 1), weekString)
        } else if isChampionshipEvent {
            // Note: Group using eventWeek(cmpIndex) if you need to support multiple CMPs
            return .cmp(nil, city)
        } else if isOffseason {
            let month = Calendar.current.component(.month, from: startDate)
            return .offseason(month)
        }
        guard let eventType = Event.EventType(rawValue: eventType) else {
            return nil
        }
        return .eventType(eventType, eventTypeString)
    }

    func eventWeek(cmpIndex: Int) -> EventWeek? {
        let eventWeek = eventWeek
        // Remap our eventWeek to give this CMP a given index
        switch eventWeek {
        case let .cmp(index, city) where index == nil:
            return .cmp(cmpIndex, city)
        default:
            return eventWeek
        }
    }
}
