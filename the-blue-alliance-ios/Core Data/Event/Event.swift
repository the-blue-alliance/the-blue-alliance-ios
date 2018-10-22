import Foundation
import TBAKit
import CoreData

public enum EventType: Int {
    case regional = 0
    case district = 1
    case districtChampionship = 2
    case championshipDivision = 3
    case championshipFinals = 4
    case districtChampionshipDivision = 5
    case festivalOfChampions = 6
    case offseason = 99
    case preseason = 100
    case unlabeled = -1
}

extension Event: Locatable, Managed {

    @discardableResult
    static func insert(with model: TBAEvent, in context: NSManagedObjectContext) -> Event {
        let predicate = NSPredicate(format: "key == %@", model.key)
        return findOrCreate(in: context, matching: predicate) { (event) in
            // Required: endDate, eventCode, eventType, key, name, startDate, year
            event.address = model.address
            event.city = model.city
            event.country = model.country

            if let district = model.district {
                event.district = District.insert(district, in: context)
            }

            event.divisionKeys = model.divisionKeys

            event.endDate = model.endDate
            event.eventCode = model.eventCode
            event.eventType = Int16(model.eventType)
            event.eventTypeString = model.eventTypeString
            event.firstEventID = model.firstEventID
            event.firstEventCode = model.firstEventCode
            event.gmapsPlaceID = model.gmapsPlaceID
            event.gmapsURL = model.gmapsURL

            event.key = model.key

            if let lat = model.lat {
                event.lat = NSNumber(value: lat)
            }
            if let lng = model.lng {
                event.lng = NSNumber(value: lng)
            }

            event.locationName = model.locationName
            event.name = model.name

            // TODO: Can we convert this to a relationship?
            event.parentEventKey = model.parentEventKey
            if let playoffType = model.playoffType {
                event.playoffType = Int16(playoffType)
            }
            event.playoffTypeString = model.playoffTypeString

            event.postalCode = model.postalCode
            event.shortName = model.shortName
            event.startDate = model.startDate
            event.stateProv = model.stateProv
            event.timezone = model.timezone

            if let webcasts = model.webcasts {
                event.webcasts = Set(webcasts.map({ (modelWebcast) -> Webcast in
                    return Webcast.insert(with: modelWebcast, for: event, in: context)
                })) as NSSet
            }

            event.website = model.website

            if let week = model.week {
                event.week = NSNumber(integerLiteral: week)
            }

            event.year = Int16(model.year)

            event.hybridType = event.calculateHybridType()
        }
    }

    // hybridType is used a mechanism for sorting Events properly in fetch result controllers... they use a variety
    // of event data to kinda "move around" events in our data model to get groups/order right
    func calculateHybridType() -> String {
        var hybridType = String(eventType)
        // Group districts together, group district CMPs together
        if isDistrictChampionshipEvent {
            // Due to how DCMP divisions come *after* everything else if sorted by default
            // This is a bit of a hack to get them to show up before DCMPs
            // Future-proofing - group DCMP divisions together based on district
            if Int(eventType) == EventType.districtChampionshipDivision.rawValue, let district = district {
                hybridType = "\(EventType.districtChampionship.rawValue)..\(district.abbreviation!).dcmpd"
            } else {
                hybridType = "\(hybridType).dcmp"
            }
        } else if let district = district, !isDistrictChampionshipEvent {
            hybridType = "\(hybridType).\(district.abbreviation!)"
        } else if Int(eventType) == EventType.offseason.rawValue, let startDate = startDate {
            // Group offseason events together by month
            let month = Calendar.current.component(.month, from: startDate)
            hybridType = "\(hybridType).\(month)"
        }
        return hybridType
    }

    public func dateString() -> String? {
        if self.startDate == nil || self.endDate == nil {
            return nil
        }

        let calendar = Calendar.current

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MMM dd"

        let longDateFormatter = DateFormatter()
        longDateFormatter.dateFormat = "MMM dd, y"

        let startDate = Date(timeIntervalSince1970: self.startDate!.timeIntervalSince1970)
        let endDate = Date(timeIntervalSince1970: self.endDate!.timeIntervalSince1970)

        if let timezone = timezone {
            let tz = TimeZone(identifier: timezone)
            shortDateFormatter.timeZone = tz
            longDateFormatter.timeZone = tz
        }

        var dateText: String?
        if startDate == endDate {
            dateText = longDateFormatter.string(from: Date(timeIntervalSince1970: endDate.timeIntervalSince1970))
        } else if calendar.component(.year, from: startDate) == calendar.component(.year, from: endDate) {
            dateText = "\(shortDateFormatter.string(from: startDate)) to \(shortDateFormatter.string(from: endDate))"
        } else {
            dateText = "\(longDateFormatter.string(from: startDate)) to \(longDateFormatter.string(from: endDate))"
        }

        return dateText
    }

    public var weekString: String {
        var weekString = "nil"
        let eventType = Int(self.eventType)
        if eventType == EventType.championshipDivision.rawValue || eventType == EventType.championshipFinals.rawValue {
            if year >= 2017, let city = city {
                weekString = "Championship - \(city)"
            } else {
                weekString = "Championship"
            }
        } else {
            switch eventType {
            case EventType.unlabeled.rawValue:
                weekString = "Other"
            case EventType.preseason.rawValue:
                weekString = "Preseason"
            case EventType.offseason.rawValue:
                guard let month = month else {
                    return "Offseason"
                }
                return "\(month) Offseason"
            case EventType.festivalOfChampions.rawValue:
                weekString = "Festival of Champions"
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
                        weekString = "Week 0.5"
                    } else {
                        weekString = "Week \(week.intValue)"
                    }
                } else {
                    weekString = "Week \(week.intValue + 1)"
                }
            }
        }
        return weekString
    }

    public var safeShortName: String {
        guard let shortName = shortName else {
            return name!
        }
        return shortName.isEmpty ? name! : shortName
    }

    public var friendlyNameWithYear: String {
        return "\(String(year)) \(safeShortName) \(eventTypeString ?? "Event")"
    }

    public var isChampionship: Bool {
        let type = Int(eventType)
        return type == EventType.championshipDivision.rawValue || type == EventType.championshipFinals.rawValue
    }

    /**
     If the event is a district championship or a district championship division.
     */
    public var isDistrictChampionshipEvent: Bool {
        let type = Int(eventType)
        return type == EventType.districtChampionshipDivision.rawValue || type == EventType.districtChampionship.rawValue
    }

    /**
     If the event is a district championship.
     */
    public var isDistrictChampionship: Bool {
        let type = Int(eventType)
        return type == EventType.districtChampionship.rawValue
    }

    public var isFoC: Bool {
        let type = Int(eventType)
        return type == EventType.festivalOfChampions.rawValue;
    }
    
    public var isPreseason: Bool {
        let type = Int(eventType)
        return type == EventType.preseason.rawValue;
    }
    
    public var isOffseason: Bool {
        let type = Int(eventType)
        return type == EventType.offseason.rawValue;
    }

    /**
     If the event is currently going, based on it's start and end dates.
     */
    public var isHappeningNow: Bool {
        guard let startDate = startDate, let endDate = endDate else {
            return false
        }
        return Date().isBetween(date: startDate, andDate: endDate.endOfDay())
    }

    public var month: String? {
        guard let startDate = startDate else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: startDate)
    }

    // An array of events that are used to represent their corresponding week in the Week selector
    // We need a full object as opposed to a number because of CMP, off-season, etc.
    // TODO: Convert this to a data model that uses a Core Data model for init but isn't a Core Data model
    static func weekEvents(for year: Int, in managedObjectContext: NSManagedObjectContext) -> [Event] {
        let events = Event.fetch(in: managedObjectContext) { (fetchRequest) in
            // Filter out CMP divisions - we don't want them below for our weeks calculation
            fetchRequest.predicate = NSPredicate(format: "year == %ld && eventType != %ld", year, EventType.championshipDivision.rawValue)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: true), NSSortDescriptor(key: "eventType", ascending: true), NSSortDescriptor(key: "endDate", ascending: true)]
        }

        // Take one event for each week(type) to use for our weekEvents array
        // ex: one Preseason, one Week 1, one Week 2..., one CMP #1, one CMP #2, one Offseason for each month
        // Jesus, take the wheel
        var handledWeeks: Set<Int> = []
        var handledTypes: Set<Int> = []
        var handledOffseasonMonths: Set<String> = []
        return Array(events.compactMap({ (event) -> Event? in
            let eventType = Int(event.eventType)
            if let week = event.week {
                // Make sure each week only shows up once
                if handledWeeks.contains(week.intValue) {
                    return nil
                }
                handledWeeks.insert(week.intValue)
                return event
            } else if eventType == EventType.championshipFinals.rawValue {
                // Always add all CMP finals
                return event
            } else if eventType == EventType.offseason.rawValue {
                // Split all off-season events in to individual month sections
                guard let month = event.month else {
                    return nil
                }
                if handledOffseasonMonths.contains(month) {
                    return nil
                }
                handledOffseasonMonths.insert(month)
                return event
            } else {
                // Make sure we only have preseason, unlabeled once
                if handledTypes.contains(eventType) {
                    return nil
                }
                handledTypes.insert(eventType)
                return event
            }
        })).sorted()
    }

}

extension Event: Comparable {

    // MARK: Comparable

    // In order... Preseason, Week 1, Week 2, ..., Week 7, CMP, Offseason, Unlabeled
    // (type: 100, week: nil) < (type: 0, week: 1)
    // (type: 99, week: nil) < (type: -1, week: nil)

    public static func <(lhs: Event, rhs: Event) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }

        let lhsType = Int(lhs.eventType)
        let rhsType = Int(rhs.eventType)

        // Preseason events should always come first
        if lhsType == EventType.preseason.rawValue || rhsType == EventType.preseason.rawValue {
            // Preseason, being 100, has the highest event type. So even though this seems backwards... it's not
            return lhsType > rhsType
        }
        // Unlabeled events go at the very end no matter what
        if lhsType == EventType.unlabeled.rawValue || rhsType == EventType.unlabeled.rawValue {
            // Same as preseason - unlabeled events are the lowest possible number so even though this line seems backwards it's not
            return lhsType > rhsType
        }
        // Offseason events come after everything besides unlabeled
        if lhsType == EventType.offseason.rawValue || rhsType == EventType.offseason.rawValue {
            // We've already handled preseason (100) so now we can assume offseason's (99) will always be the highest type
            return lhsType < rhsType
        }
        // CMP finals come after everything besides offseason, unlabeled
        if lhsType == EventType.championshipFinals.rawValue || rhsType == EventType.championshipFinals.rawValue {
            // Make sure we handle that districtCMPDivision case
            if lhsType == EventType.districtChampionshipDivision.rawValue || rhsType == EventType.districtChampionshipDivision.rawValue {
                return lhsType > rhsType
            } else {
                return lhsType < rhsType
            }
        }
        // CMP divisions are next
        if lhsType == EventType.championshipDivision.rawValue || rhsType == EventType.championshipDivision.rawValue {
            // Make sure we handle that districtCMPDivision case
            if lhsType == EventType.districtChampionshipDivision.rawValue || rhsType == EventType.districtChampionshipDivision.rawValue {
                return lhsType > rhsType
            } else {
                return lhsType < rhsType
            }
        }
        // Throw Festival of Champions at the end, since it's the last event
        if lhsType == EventType.festivalOfChampions.rawValue || rhsType == EventType.festivalOfChampions.rawValue {
            return lhsType < rhsType
        }
        // EVERYTHING ELSE (districts, regionals, DCMPs, DCMP divisions) has weeks. This is just an easy sort... which event has a first week
        // Only weird thing is how we're sorting events that have the same weeks. It goes...
        // Regional < District < DCMP Division < DCMP
        if let lhsWeek = lhs.week, let rhsWeek = rhs.week {
            if lhsWeek == rhsWeek {
                // Make sure we handle the weird case of district championship divisions being a higher number than DCMPs
                if (lhsType == EventType.districtChampionshipDivision.rawValue || rhsType == EventType.districtChampionshipDivision.rawValue) &&
                    (lhsType == EventType.districtChampionship.rawValue || rhsType == EventType.districtChampionship.rawValue) {
                    return lhsType > rhsType
                } else {
                    return lhsType < rhsType
                }
            } else {
                return lhsWeek.intValue < rhsWeek.intValue
            }
        }
        return false
    }

}
