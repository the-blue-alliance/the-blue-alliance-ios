//
//  Event.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct Event: Decodable, Sendable {
    public var key: EventKey
    public var name: String
    public var eventCode: String
    public var eventTypeInt: Int
    public var eventType: EventType {
        EventType(rawValue: eventTypeInt) ?? .unlabeled
    }
    public var eventTypeString: String
    public var district: District?
    public var city: String?
    public var stateProv: String?
    public var country: String?
    public var startDate: Date
    public var endDate: Date
    public var year: Year
    public var shortName: String?
    public var week: Int?
    public var address: String?
    public var postalCode: String?
    public var gmapsPlaceID: String?
    public var gmapsURL: String?
    public var lat: Double?
    public var lng: Double?
    public var locationName: String?
    public var timezone: String?
    public var website: String?
    public var firstEventID: String?
    public var firstEventCode: String?
    public var webcasts: [Webcast]
    public var divisionKeys: [EventKey]
    public var parentEventKey: EventKey?
    public var playoffType: PlayoffType? {
        guard let playoffTypeInt else {
            return nil
        }
        return PlayoffType(rawValue: playoffTypeInt) ?? .custom
    }
    public var playoffTypeInt: Int?
    public var playoffTypeString: String?

    enum CodingKeys: String, CodingKey {
        case key
        case name
        case eventCode = "event_code"
        case eventTypeInt = "event_type"
        case district
        case city
        case stateProv = "state_prov"
        case country
        case startDate = "start_date"
        case endDate = "end_date"
        case year
        case shortName = "short_name"
        case eventTypeString = "event_type_string"
        case week
        case address
        case postalCode = "postal_code"
        case gmapsPlaceID = "gmaps_place_id"
        case gmapsURL = "gmaps_url"
        case lat
        case lng
        case locationName = "location_name"
        case timezone
        case website
        case firstEventID = "first_event_id"
        case firstEventCode = "first_event_code"
        case webcasts
        case divisionKeys = "division_keys"
        case parentEventKey = "parent_event_key"
        case playoffTypeInt = "playoff_type"
        case playoffTypeString = "playoff_type_string"
    }

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

    public enum PlayoffType: Int, Sendable {
        // Standard Brackets
        case bracket16Team = 1
        case bracket8Team = 0
        case bracket4Team = 2
        case bracket2Team = 9
        
        // 2015 is special
        case avgScore8Team = 3
        
        // Round Robin
        case roundRobin6Team = 4
        
        // Double Elimination Bracket
        // The legacy style is just a basic internet bracket
        case legacyDoubleElim8Team = 5
        // The "regular" style is the one that FIRST plans to trial for the 2023 season
        // https://www.firstinspires.org/robotics/frc/blog/2022-timeout-and-playoff-tournament-updates
        case doubleElim8Team = 10
        // The bracket used for districts with four divisions
        case doubleElim4Team = 11
        
        // Festival of Champions
        case bo5Finals = 6
        
        case bo3Finals = 7
        
        case custom = 8
        
        public var playoffTypeString: String {
            switch self {
            case .bracket16Team:
                return "Elimination Bracket (16 Alliances)"
            case .bracket8Team:
                return "Elimination Bracket (8 Alliances)"
            case .bracket4Team:
                return "Elimination Bracket (4 Alliances)"
            case .bracket2Team:
                return "Elimination Bracket (2 Alliances)"
            case .avgScore8Team:
                return "Average Score (8 Alliances)"
            case .roundRobin6Team:
                return "Round Robin (6 Alliances)"
            case .legacyDoubleElim8Team:
                return "Legacy Double Elimination Bracket (8 Alliances)"
            case .doubleElim8Team:
                return "Double Elimination Bracket (8 Alliances)"
            case .doubleElim4Team:
                return "Double Elimination Bracket (4 Alliances)"
            case .bo5Finals:
                return "Best of 5 Finals"
            case .bo3Finals:
                return "Best of 3 Finals"
            case .custom:
                return "Custom"
            }
        }
    }
}

extension Event: Equatable, Hashable {}
