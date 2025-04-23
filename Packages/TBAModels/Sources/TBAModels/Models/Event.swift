//
//  Event.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation
import Algorithms
import TBAUtils

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
}

extension Event: Equatable, Hashable {}

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

    private static let doubleElimTypes: [PlayoffType] = [.legacyDoubleElim8Team, .doubleElim8Team, .doubleElim4Team]

    private static let bracketTypes: [PlayoffType] = [.bracket2Team, .bracket4Team, .bracket8Team, .bracket16Team]

    var isDoubleElimType: Bool {
        PlayoffType.doubleElimTypes.contains(self)
    }

    var isBracketType: Bool {
        PlayoffType.bracketTypes.contains(self)
    }
}

extension Event {

    public var startMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: startDate)
    }

    /**
     hybridType is used a mechanism for sorting Events properly in lists. It use a variety
     of event data to kinda "move around" events in our data model to get groups/order right.
     Note - hybrid type is ONLY safe to sort by for events within the same year.
     Sorting by hybrid type for events across years will put events together roughly by their types,
     but not necessairly their true sorts (see Comparable for a true sort)
     */
    // TODO: Convert hybridType into enum
    public var hybridType: String {
        // Group districts together, group district CMPs together
        if isDistrictChampionshipEvent {
            // Due to how DCMP divisions come *after* everything else if sorted by default
            // This is a bit of a hack to get them to show up before DCMPs
            // Future-proofing - group DCMP divisions together based on district
            if isDistrictChampionshipDivision, let district = district {
                return "\(EventType.districtChampionship.rawValue)..\(district.abbreviation).dcmpd"
            }
            return "\(eventType).dcmp"
        } else if let district = district, !isDistrictChampionshipEvent {
            return "\(eventType).\(district.abbreviation)"
        } else if isOffseason {
            // Group offseason events together by month
            // Pad our month with a leading `0` - this is so we can have "99.9" < "99.11"
            // (September Offseason to be sorted before November Offseason). Swift will compare
            // each character's hex value one-by-one, which means we'll fail at "9" < "1".
            let monthString = String(format: "%02d", startDate.month)
            return "\(eventType).\(monthString)"
        }
        return "\(eventType)"

    }

    public var displayName: String {
        let fallbackName = name.isEmpty ? key : name
        guard let shortName = shortName else {
            return fallbackName
        }
        return shortName.isEmpty ? fallbackName : shortName
    }

    public var displayLocation: String? {
        let location = [city, stateProv, country].compactMap { dateComponent in
            guard let dateComponent else {
                return nil
            }
            return dateComponent.isEmpty ? nil : dateComponent
        }.joined(separator: ", ")
        return location.isEmpty ? nil : location
    }

    public var displayDates: String {
        let calendar = Calendar.current

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MMM dd"

        let longDateFormatter = DateFormatter()
        longDateFormatter.dateFormat = "MMM dd, y"

        if startDate == endDate {
            return shortDateFormatter.string(from: endDate)
        } else if calendar.component(.year, from: startDate) == calendar.component(.year, from: endDate) {
            return "\(shortDateFormatter.string(from: startDate)) to \(shortDateFormatter.string(from: endDate))"
        }
        return "\(shortDateFormatter.string(from: startDate)) to \(longDateFormatter.string(from: endDate))"
    }

    public var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: startDate)
    }

    public var weekString: String {
        if eventType == .championshipDivision || eventType == .championshipFinals {
            if self.year >= 2017, let city = city {
                return "Championship - \(city)"
            }
            return "Championship"
        } else {
            switch eventType {
            case .unlabeled:
                return "Other"
            case .preseason:
                return "Preseason"
            case .offseason:
                return "\(month) Offseason"
            case .festivalOfChampions:
                return "Festival of Champions"
            default:
                guard let week = week else {
                    return "Other"
                }

                /**
                 * Special cases for 2016:
                 * Week 1 is actually Week 0.5, eveything else is one less
                 * See http://www.usfirst.org/roboticsprograms/frc/blog-The-Palmetto-Regional
                 */
                if year == 2016 {
                    if week == 0 {
                        return "Week 0.5"
                    }
                    return "Week \(week)"
                }
                return "Week \(week + 1)"
            }
        }
    }

    /**
     If the event is currently going, based on it's start and end dates.
     */
    public var isHappeningNow: Bool {
        return Date().isBetween(date: startDate, andDate: endDate.endOfDay())
    }
}
