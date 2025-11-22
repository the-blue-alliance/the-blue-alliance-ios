//
//  Event+TBA.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/23/25.
//

import Foundation

public extension Event {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    var startDate: Date {
        Self.dateFormatter.date(from: startDateString)!
    }

    var startMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: startDate)
    }

    private var startMonthComponent: Int {
        Calendar.current.component(.month, from: startDate)
    }

    var endDate: Date {
        Self.dateFormatter.date(from: endDateString)!
    }

    var hybridType: HybridType {
        if let district {
            if isDistrictChampionshipDivision {
                return .districtCMPDivision(district)
            } else if isDistrictChampionshipEvent {
                return .districtCMP(district)
            }
            return .districtEvent(district, self)
        } else if isOffseason {
            return .offseasonEvent(self)
        }
        return .event(self)
    }

    var weekString: String {
        if isDistrictChampionshipEvent {
            if year >= 2017, let city {
                return "Championship - \(city)"
            }
            return "Championship"
        } else {
            switch eventType {
            case EventType.unlabeled.rawValue:
                return "Other"
            case EventType.preseason.rawValue:
                return "Preseason"
            case EventType.offseason.rawValue:
                return "\(startMonth) Offseason"
            case EventType.festivalOfChampions.rawValue:
                return "Festival of Champions"
            default:
                guard let week else {
                    return "Other"
                }

                if year == 2016 {
                    /**
                     * Special cases for 2016:
                     * Week 1 is actually Week 0.5, eveything else is one less
                     * See http://www.usfirst.org/roboticsprograms/frc/blog-The-Palmetto-Regional
                     */
                    if week == 0 {
                        return "Week 0.5"
                    }
                    return "Week \(week)"
                } else if year == 2021 {
                    if week == 0 {
                        return "Participation"
                    } else if week == 6 {
                        return "FIRST Innovation Challenge"
                    } else if week == 7 {
                        return "INFINITE RECHARGE At Home Challenge"
                    } else if week == 8 {
                        return "Game Design Challenge"
                    } else if week == 9 {
                        return "Awards"
                    }
                }
                return "Week \(week + 1)"
            }
        }
    }

    var displayName: String {
        let fallbackName = name.isEmpty ? key : name
        guard let shortName else {
            return fallbackName
        }
        return shortName.isEmpty ? fallbackName : shortName
    }

    var displayNameWithYear: String {
        return "\(displayName) \(year)"
    }

    var displayLocation: String? {
        let location = [city, stateProv, country].compactMap { dateComponent in
            guard let dateComponent else {
                return nil
            }
            return dateComponent.isEmpty ? nil : dateComponent
        }.joined(separator: ", ")
        return location.isEmpty ? nil : location
    }

    var displayDates: String {
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
}

/// hybridType is used a mechanism for sorting Events properly in lists. It use a variety
/// of event data to kinda "move around" events in our data model to get groups/order right.
/// Note - hybrid type is ONLY safe to sort by for events within the same year.
/// Sorting by hybrid type for events across years will put events together roughly by their types,
/// but not necessairly their true sorts (see Comparable for a true sort)
public enum HybridType: Comparable {
    case event(Event)
    case districtEvent(District, Event)
    case districtCMP(District)
    case districtCMPDivision(District)
    case offseasonEvent(Event)

    public var sectionTitle: String {
        switch self {
        case .event(let event):
            return "\(event.eventTypeString) Events"
        case .districtEvent(let district, _):
            return "\(district.name) District Events"
        case .districtCMPDivision(let district):
            return "\(district.name) Championship Divisions"
        case .districtCMP(_):
            return "District Championship Events"
        case .offseasonEvent(let event):
            return "\(event.startMonth) Offseason Events"
        }
    }

    public static func < (lhs: HybridType, rhs: HybridType) -> Bool {
        // First, compare by primary event type (Int)
        let lhsPrimaryType = lhs.primaryEventType
        let rhsPrimaryType = rhs.primaryEventType

        if lhsPrimaryType != rhsPrimaryType {
            return lhsPrimaryType < rhsPrimaryType
        }

        // Primary types are equal, now use secondary/tertiary sorting
        // This matches the string comparison logic from hybridType
        switch (lhs, rhs) {
        case (.districtEvent(let lhsDistrict, _), .districtEvent(let rhsDistrict, _)):
            // For district events of same type, sort by district abbreviation
            return lhsDistrict.abbreviation < rhsDistrict.abbreviation

        case (.districtCMPDivision(let lhsDistrict), .districtCMPDivision(let rhsDistrict)):
            // For district CMP divisions, sort by district abbreviation
            return lhsDistrict.abbreviation < rhsDistrict.abbreviation

        case (.districtCMPDivision(_), .districtCMP(_)):
            // dcmpd (divisions) should sort before dcmp (regular championship)
            // This matches the string logic where "2..{abbrev}.dcmpd" < "2.dcmp"
            return true

        case (.districtCMP(_), .districtCMPDivision(_)):
            // dcmp (regular championship) should sort after dcmpd (divisions)
            return false

        case (.offseasonEvent(let lhsEvent), .offseasonEvent(let rhsEvent)):
            // Sort offseason events by month
            let lhsMonth = Calendar.current.component(.month, from: lhsEvent.startDate)
            let rhsMonth = Calendar.current.component(.month, from: rhsEvent.startDate)
            return lhsMonth < rhsMonth

        default:
            // All other cases are equal at this level
            return false
        }
    }

    /// Returns the primary event type for sorting
    private var primaryEventType: Int {
        switch self {
        case .event(let event):
            return event.eventType
        case .districtEvent(_, let event):
            return event.eventType
        case .districtCMP(_), .districtCMPDivision(_):
            // Both district CMP types share the same primary type
            return Event.EventType.districtChampionship.rawValue
        case .offseasonEvent(let event):
            return event.eventType
        }
    }
}


// extension Event {
//    /**
//     If the event is currently going, based on it's start and end dates.
//     */
//    public var isHappeningNow: Bool {
//        let currentDate = Date()
//        guard startDate <= endDate else {
//            return false
//        }
//        return currentDate >= startDate && currentDate <= endDate
//    }
// }
