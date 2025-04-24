//
//  Event.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/23/25.
//

import Foundation

extension Event {

    public var startMonth: Int {
        return Calendar.current.component(.month, from: startDate)
    }

    public var startMonthString: String {
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
            let monthString = String(format: "%02d", startMonth)
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
                return "\(startMonthString) Offseason"
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
        let currentDate = Date()
        guard startDate <= endDate else {
            return false
        }
        return currentDate >= startDate && currentDate <= endDate
    }

}
