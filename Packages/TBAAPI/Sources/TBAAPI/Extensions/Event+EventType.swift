//
//  Event+EventType.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/23/25.
//

public extension Event {
    enum EventType: Int {
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

    var isDistrictChampionshipEvent: Bool {
        isDistrictChampionship || isDistrictChampionshipDivision
    }

    var isDistrictChampionshipDivision: Bool {
        eventType == EventType.districtChampionshipDivision.rawValue
    }

    var isDistrictChampionship: Bool {
        eventType == EventType.districtChampionship.rawValue
    }

    var isChampionshipEvent: Bool {
        isCMPDivision || isCMPFinals
    }

    var isCMPDivision: Bool {
        eventType == EventType.championshipDivision.rawValue
    }

    var isCMPFinals: Bool {
        eventType == EventType.championshipFinals.rawValue
    }

    var isRemote: Bool {
        eventType == EventType.remote.rawValue
    }

    var isOffseason: Bool {
        eventType == EventType.offseason.rawValue
    }

    var isUnlabeled: Bool {
        eventType == EventType.unlabeled.rawValue
    }
}

extension Event.EventType: Comparable {
    public static func < (lhs: Event.EventType, rhs: Event.EventType) -> Bool {
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
        let adjustValue: ((Event.EventType) -> Double) = { eventType in
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
