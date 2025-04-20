//
//  EventType.swift
//  TBAModels
//
//  Created by Zachary Orr on 4/19/25.
//

/*
public enum EventType: Int, CaseIterable, Hashable {
    case regional = 0
    case district = 1
    case districtChampionship = 2
    case championshipDivision = 3
    case championshipFinals = 4
    case districtChampionshipDivision = 5
    case festivalOfChampions = 6
    case remote = 7
    case offseason = 99
    case preseason = 100
    case unlabeled = -1
}

extension EventType: Comparable {
    public static func < (lhs: EventType, rhs: EventType) -> Bool {
        // Float preseasons to the top
        if lhs == .preseason || rhs == .preseason {
            return lhs == .preseason
        }
        // Drop unlabeled to the bottom
        if lhs == .unlabeled || rhs == .unlabeled {
            return rhs == .unlabeled
        }
        // Note to Zach: I got tired of finding the right way to do this -
        // we're going with this way
        // Put Remote up with Regional/District
        // Put DCMP Divisions before DCMP
        let adjustValue: ((EventType) -> Double) = { eventType in
            if eventType == .remote {
                return 1.1
            }
            if eventType == .districtChampionshipDivision {
                return 1.2
            }
            return Double(eventType.rawValue)
        }
        let adjustedLHSValue = adjustValue(lhs)
        let adjustedRHSValue = adjustValue(rhs)
        return adjustedLHSValue < adjustedRHSValue
    }
}

extension Event {
    public var isDistrictChampionshipEvent: Bool {
        return isDistrictChampionship || isDistrictChampionshipDivision
    }

    public var isDistrictChampionshipDivision: Bool {
        return eventType == .districtChampionshipDivision
    }

    public var isDistrictChampionship: Bool {
        return eventType == .districtChampionship
    }

    public var isChampionshipEvent: Bool {
        return isCMPDivision || isCMPFinals
    }

    public var isCMPDivision: Bool {
        return eventType == .championshipDivision
    }

    public var isCMPFinals: Bool {
        return eventType == .championshipFinals
    }

    public var isOffseason: Bool {
        eventType == .offseason
    }
}
*/
