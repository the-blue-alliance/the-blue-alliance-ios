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

    /**
     Insert Events for a year with values from TBAKit Event models in to the managed object context.

     This method manages deleting orphaned Events for a year.

     - Parameter events: The TBAKit Event representations to set values from.

     - Parameter year: The year for the Events.

     - Parameter context: The NSManagedContext to insert the Event in to.
     */
    static func insert(_ events: [TBAEvent], year: Int, in context: NSManagedObjectContext) {
        // Fetch all of the previous Events for this year
        let oldEvents = Event.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(Event.year), year)
        }

        // Insert new Events for this year
        let events = events.map({
            return Event.insert($0, in: context)
        })

        // Delete orphaned Events for this year
        Set(oldEvents).subtracting(Set(events)).forEach({
            context.delete($0)
        })
    }

    /**
     Insert an Event with values from a TBAKit Event model in to the managed object context.

     This method manages deleting orphaned Webcasts.

     - Parameter model: The TBAKit Event representation to set values from.

     - Parameter context: The NSManagedContext to insert the Event in to.

     - Returns: The inserted Event.
     */
    @discardableResult
    static func insert(_ model: TBAEvent, in context: NSManagedObjectContext) -> Event {
        let predicate = NSPredicate(format: "key == %@", model.key)
        return findOrCreate(in: context, matching: predicate) { (event) in
            // Required: endDate, eventCode, eventType, key, name, startDate, year
            event.address = model.address
            event.city = model.city
            event.country = model.country

            event.updateToOneRelationship(relationship: #keyPath(Event.district), newValue: model.district, newObject: {
                return District.insert($0, in: context)
            })

            event.updateToManyRelationship(relationship: #keyPath(Event.divisions), newValues: model.divisionKeys.map({
                return EventKey.insert(withKey: $0, in: context)
            }))

            event.endDate = model.endDate
            event.eventCode = model.eventCode
            event.eventType = model.eventType as NSNumber
            event.eventTypeString = model.eventTypeString
            event.firstEventID = model.firstEventID
            event.firstEventCode = model.firstEventCode
            event.gmapsPlaceID = model.gmapsPlaceID
            event.gmapsURL = model.gmapsURL

            event.key = model.key
            event.lat = model.lat as NSNumber?
            event.lng = model.lng as NSNumber?

            event.locationName = model.locationName
            event.name = model.name

            event.updateToOneRelationship(relationship: #keyPath(Event.parentEvent), newValue: model.parentEventKey, newObject: {
                return EventKey.insert(withKey: $0, in: context)
            })
            event.playoffType = model.playoffType as NSNumber?
            event.playoffTypeString = model.playoffTypeString

            event.postalCode = model.postalCode
            event.shortName = model.shortName
            event.startDate = model.startDate
            event.stateProv = model.stateProv
            event.timezone = model.timezone

            event.insert(model.webcasts ?? [])

            event.website = model.website
            event.week = model.week as NSNumber?
            event.year = model.year as NSNumber

            event.hybridType = event.calculateHybridType()
        }
    }

    /**
     Insert Event Alliances with values from a TBAKit Alliance models in to the managed object context.

     This method will manage setting up an Event Alliance's relationship to an Event and the deletion of oprhaned Event Alliances on the Event.

     - Parameter alliances: The TBAKit Alliance representations to set values from.
     */
    func insert(_ alliances: [TBAAlliance]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        // Fetch all of the previous EventAlliances for this Event
        let oldAlliances = self.alliances?.array as? [EventAlliance] ?? []

        // Insert new EventAlliances for this year
        let alliances = alliances.map({
            return EventAlliance.insert($0, eventKey: key!, in: managedObjectContext)
        })

        // Delete orphaned EventAlliances for this Event
        Set(oldAlliances).subtracting(Set(alliances)).forEach({
            managedObjectContext.delete($0)
        })
        self.alliances = NSOrderedSet(array: alliances)
    }

    /**
     Insert Awards with values from a TBAKit Award models in to the managed object context.

     This method will manage setting up an Award's relationship to an Event and the deletion of oprhaned Awards on the Event.

     - Parameter awards: The TBAKit Award representations to set values from.
     */
    func insert(_ awards: [TBAAward]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.awards), newValues: awards.map({
            return Award.insert($0, in: managedObjectContext)
        }))
    }

    /**
     Insert Awards for a given TeamKey with values from a TBAKit Award models in to the managed object context.

     This method will manage setting up an Award's relationship to an Event and the deletion of oprhaned Awards for a TeamKey on the Event.

     - Parameter awards: The TBAKit Award representations to set values from.

     - Parameter teamKey: The TeamKey the Awards belong to.
     */
    func insert(_ awards: [TBAAward], teamKey: TeamKey) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        // Fetch all of the previous Awards for this Event/TeamKey
        let oldAwards = Award.fetch(in: managedObjectContext) {
            $0.predicate = NSPredicate(format: "SUBQUERY(%K, $r, $r.teamKey.key == %@).@count == 1",
                                       #keyPath(Award.recipients), teamKey.key!)
        }

        // Insert new Awards
        let awards = awards.map({ (model: TBAAward) -> Award in
            let a = Award.insert(model, in: managedObjectContext)
            addToAwards(a)
            return a
        })

        // Delete orphaned Awards for this Event/TeamKey
        Set(oldAwards).subtracting(Set(awards)).forEach({
            managedObjectContext.delete($0)
        })
    }

    /**
     Insert an EventInsight with values from TBAKit EventInsight model in to the managed object context.

     This method will manage setting up an EventInsight's relationship to an Event.

     - Parameter insights: The TBAKit EventInsights representations to set values from.
     */
    func insert(_ insights: TBAEventInsights) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToOneRelationship(relationship: #keyPath(Event.insights), newValue: insights, newObject: {
            return EventInsights.insert($0, eventKey: key!, in: managedObjectContext)
        })
    }

    /**
     Insert Matches with values from TBAKit Match models in to the managed object context.

     This method will manage setting up a Match's relationship to an Event and the deletion of oprhaned Matches on the Event.

     - Parameter matches: The TBAKit Match representations to set values from.
     */
    func insert(_ matches: [TBAMatch]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.matches), newValues: matches.map({
            return Match.insert($0, event: self, in: managedObjectContext)
        }))
    }

    /**
     Insert Rankings with values from TBAKit Event Ranking models in to the managed object context.

     This method manages setting up an Event's relationship to Rankings.

     - Parameter rankings: The TBAKit Event Ranking representations to set values from.

     - Parameter sortOrderInfo: The TBA EventRankingSortOrder representations for this Ranking info

     - Parameter extraStatsInfo: The TBA EventRankingSortOrder representations for this Ranking info
     */
    func insert(_ rankings: [TBAEventRanking], sortOrderInfo: [TBAEventRankingSortOrder]?, extraStatsInfo: [TBAEventRankingSortOrder]?) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.rankings), newValues: rankings.map({
            return EventRanking.insert($0, sortOrderInfo: sortOrderInfo, extraStatsInfo: extraStatsInfo, eventKey: key!, in: managedObjectContext)
        }))
    }

    /**
     Insert EventTeamStats with values from a TBAKit Stat models in to the managed object context.

     This method manages setting up an Event's relationship to an EventTeamStats as well as deleting orphaned EventTeamStats

     - Parameter stats: The TBAKit Stat representation to set values from.
     */
    func insert(_ stats: [TBAStat]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.stats), newValues: stats.map({
            return EventTeamStat.insert($0, eventKey: key!, in: managedObjectContext)
        }))
    }

    /**
     Insert an Event Status with values from a TBAKit Event Status model in to the managed object context.

     This method manages setting up an Event's relationship to an Event Status, as well as setting up an EventStatusQual's Ranking's relationship to the Event

     - Parameter status: The TBAKit Event Status representation to set values from.
     */
    func insert(_ status: TBAEventStatus) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        let status = EventStatus.insert(status, in: managedObjectContext)
        status.qual?.ranking?.event = self

        addToStatuses(status)
    }

    /**
     Insert Teams with values from TBAKit Team models in to the managed object context.

     This method manages setting up an Event's relationship to Teams.

     - Parameter teams: The TBAKit Team representations to set values from.
     */
    func insert(_ teams: [TBATeam]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.teams = NSSet(array: teams.map({
            return Team.insert($0, in: managedObjectContext)
        }))
    }

    /**
     Insert Webcasts with values from TBAKit Webcast models in to the managed object context.

     This method manages setting up an Event's relationship to Webcasts and deleting orphaned Webcasts.

     - Parameter webcasts: The TBAKit Webcast representations to set values from.
     */
    func insert(_ webcasts: [TBAWebcast]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.webcasts), newValues: webcasts.map({
            return Webcast.insert($0, in: managedObjectContext)
        }))
    }

    var isOrphaned: Bool {
        // Event is a root object, so it should never be an orphan
        return false
    }
    
    /// Event's shouldn't really be deleted, but sometimes they can be
    public override func prepareForDeletion() {
        super.prepareForDeletion()

        (webcasts?.allObjects as? [Webcast])?.forEach({
            if $0.events!.onlyObject(self) {
                // Webcast will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.removeFromEvents(self)
            }
        })
    }

    // hybridType is used a mechanism for sorting Events properly in fetch result controllers... they use a variety
    // of event data to kinda "move around" events in our data model to get groups/order right
    func calculateHybridType() -> String {
        var hybridType = eventType!.stringValue
        // Group districts together, group district CMPs together
        if isDistrictChampionshipEvent {
            // Due to how DCMP divisions come *after* everything else if sorted by default
            // This is a bit of a hack to get them to show up before DCMPs
            // Future-proofing - group DCMP divisions together based on district
            if eventType!.intValue == EventType.districtChampionshipDivision.rawValue, let district = district {
                hybridType = "\(EventType.districtChampionship.rawValue)..\(district.abbreviation!).dcmpd"
            } else {
                hybridType = "\(hybridType).dcmp"
            }
        } else if let district = district, !isDistrictChampionshipEvent {
            hybridType = "\(hybridType).\(district.abbreviation!)"
        } else if eventType!.intValue == EventType.offseason.rawValue, let startDate = startDate {
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
        let eventType = self.eventType!.intValue
        if eventType == EventType.championshipDivision.rawValue || eventType == EventType.championshipFinals.rawValue {
            if year!.intValue >= 2017, let city = city {
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
        return "\(year!.stringValue) \(safeShortName) \(eventTypeString ?? "Event")"
    }

    public var isChampionship: Bool {
        let type = eventType!.intValue
        return type == EventType.championshipDivision.rawValue || type == EventType.championshipFinals.rawValue
    }

    /**
     If the event is a district championship or a district championship division.
     */
    public var isDistrictChampionshipEvent: Bool {
        let type = eventType!.intValue
        return type == EventType.districtChampionshipDivision.rawValue || type == EventType.districtChampionship.rawValue
    }

    /**
     If the event is a district championship.
     */
    public var isDistrictChampionship: Bool {
        return eventType!.intValue == EventType.districtChampionship.rawValue
    }

    public var isFoC: Bool {
        return eventType!.intValue == EventType.festivalOfChampions.rawValue;
    }
    
    public var isPreseason: Bool {
        return eventType!.intValue == EventType.preseason.rawValue;
    }
    
    public var isOffseason: Bool {
        return eventType!.intValue == EventType.offseason.rawValue;
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
            let eventType = event.eventType!.intValue
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
            return lhs.year!.intValue < rhs.year!.intValue
        }

        let lhsType = lhs.eventType!.intValue
        let rhsType = rhs.eventType!.intValue

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
