import CoreData
// import CoreSpotlight
// import MyTBAKit
// import Search
import TBAKit
// import TBAProtocols
import TBAUtils

/*
// https://github.com/the-blue-alliance/the-blue-alliance/blob/master/consts/event_type.py
public enum EventType: Int, CaseIterable {
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

extension EventType: Comparable {

    public static func < (lhs: EventType, rhs: EventType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

}
*/

extension TBAEvent {

    /*
    public var eventType: EventType? {
        guard let eventTypeInt = getValue(\Event.eventTypeRaw)?.intValue else {
            return nil
        }
        guard let eventType = EventType(rawValue: eventTypeInt) else {
            return nil
        }
        return eventType
    }
    */

    /*
    public var key: String {
        guard let key = getValue(\Event.keyRaw) else {
            fatalError("Save Event before accessing key")
        }
        return key
    }

    public var year: Int {
        guard let year = getValue(\Event.yearRaw)?.intValue else {
            fatalError("Save Event before accessing year")
        }
        return year
    }
    */

    /*
    public var alliances: NSOrderedSet {
        guard let alliances = getValue(\Event.alliancesRaw) else {
            fatalError("Save Event before accessing alliances")
        }
        return alliances
    }
    */

    /*
    public var weekString: String {
        guard let eventType = eventType else {
            return "Unknown"
        }

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
                guard let month = month else {
                    return "Offseason"
                }
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

    public var safeShortName: String {
        guard let name = name else {
            return key
        }
        guard let shortName = shortName else {
            return name
        }
        return shortName.isEmpty ? name : shortName
    }

    public var safeNameYear: String {
        guard let name = name else {
            return key
        }
        return name.isEmpty ? key : "\(year) \(name)"
    }

    public var friendlyNameWithYear: String {
        guard let name = name else {
            return key
        }
        var parts = [String(year)]
        if let shortName = shortName {
            parts.append(shortName)

            // Append the event type if we have the shortname
            if let eventTypeString = eventTypeString {
                parts.append(eventTypeString)
            } else {
                parts.append("Event")
            }
        } else {
            parts.append(name)
        }
        return parts.joined(separator: " ")
    }

    /**
     If the event is a CMP division or a CMP finals field.
     */
    public var isChampionshipEvent: Bool {
        return isChampionshipDivision || isChampionshipFinals
    }

    /**
     If the event is a CMP division.
     */
    public var isChampionshipDivision: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .championshipDivision
    }

    /**
     If the event is a CMP finals field.
     */
    public var isChampionshipFinals: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .championshipFinals
    }

    /**
     If the event is a district championship or a district championship division.
     */
    public var isDistrictChampionshipEvent: Bool {
        return isDistrictChampionshipDivision || isDistrictChampionship
    }

    /**
     If the event is a district championship.
     */
    public var isDistrictChampionshipDivision: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .districtChampionshipDivision
    }

    /**
     If the event is a district championship.
     */
    public var isDistrictChampionship: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .districtChampionship
    }

    /**
     If the event is a Festival of Champions event.
     */
    public var isFoC: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .festivalOfChampions
    }

    /**
     If the event is a preseason event.
     */
    public var isPreseason: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .preseason
    }

    /**
     If the event is an offseason event.
     */
    public var isOffseason: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .offseason
    }

    /**
     If the event is a regional event.
     */
    public var isRegional: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .regional
    }

    /**
     If the event is an unlabeled event.
     */
    public var isUnlabeled: Bool {
        guard let eventType = eventType else {
            return false
        }
        return eventType == .unlabeled
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

    /**
     If the event is happening within the coming week, based on it's start and end dates.
     */
    public var isHappeningThisWeek: Bool {
        guard let startDate = startDate, let endDate = endDate else {
            return false
        }
        let minusWeek = DateComponents(day: -7)
        guard let startOfWeek = Calendar.current.date(byAdding: minusWeek, to: startDate) else {
            return false
        }
        return Date().isBetween(date: startOfWeek, andDate: endDate.endOfDay())
    }

    public var month: String? {
        guard let startDate = startDate else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: startDate)
    }
    */

}

@objc(TBAEvent)
public class TBAEvent: NSManagedObject {

    @NSManaged var address: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var endDate: Date?
    @NSManaged var eventCode: String?
    @NSManaged var eventType: NSNumber?
    @NSManaged var eventTypeString: String?
    @NSManaged var firstEventCode: String?
    @NSManaged var firstEventID: String?
    @NSManaged var gmapsPlaceID: String?
    @NSManaged var gmapsURL: String?
    @NSManaged var hybridType: String?
    @NSManaged var key: String
    @NSManaged var lat: NSNumber?
    @NSManaged var lng: NSNumber?
    @NSManaged var locationName: String?
    @NSManaged var name: String?
    @NSManaged var playoffType: NSNumber?
    @NSManaged var playoffTypeString: String?
    @NSManaged var postalCode: String?
    @NSManaged var shortName: String?
    @NSManaged var startDate: Date?
    @NSManaged var stateProv: String?
    @NSManaged var timezone: String?
    @NSManaged var website: String?
    @NSManaged var week: NSNumber? // TODO: Convert to Int (Int32 in Core Data?)
    @NSManaged var year: NSNumber
    @NSManaged var alliances: NSOrderedSet? // TODO: How do we get some generics here?
    // @NSManaged var awards: Set<Award>?
    // @NSManaged var district: District?
    @NSManaged var divisions: Set<TBAEvent>?
    // @NSManaged var insights: EventInsights?
    // @NSManaged var matches: Set<Match>?
    @NSManaged var parentEvent: TBAEvent?
    // @NSManaged var points: Set<DistrictEventPoints>?
    // @NSManaged var rankings: Set<EventRanking>?
    // @NSManaged var stats: Set<EventTeamStat>?
    // @NSManaged var status: Status?
    // @NSManaged var statuses: Set<EventStatus>?
    // @NSManaged var teams: Set<Team>?
    @NSManaged var webcasts: Set<TBAWebcast>
}

extension TBAEvent: Managed {

    /**
     Insert Events for a year with values from TBAKit Event models in to the managed object context.

     This method manages deleting orphaned Events for a year.

     - Parameter events: The TBAKit Event representations to set values from.

     - Parameter year: The year for the Events.

     - Parameter context: The NSManagedContext to insert the Event in to.
     */
    public static func insert(_ events: [APIEvent], year: Int, in context: NSManagedObjectContext) async throws -> [TBAEvent] {
        // Fetch all of the previous Events for this year
        let oldEvents = try await TBAEvent.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(TBAEvent.year), year)
        }

        // Insert new Events for this year
        var newEvents: [TBAEvent] = []
        for event in events {
            newEvents.append(try await TBAEvent.insert(event, in: context))
        }

        // Delete orphaned Events for this year
        Set(oldEvents).subtracting(Set(newEvents)).forEach({
            context.delete($0)
        })

        return newEvents
    }

    /**
     Insert an Event with a specified key in to the managed object context.

     - Parameter key: The key for the Event.

     - Parameter context: The NSManagedContext to insert the Event in to.

     - Returns: The inserted Event.
     */
    public static func insert(_ key: String, in context: NSManagedObjectContext) async throws -> TBAEvent {
        let predicate = TBAEvent.predicate(key: key)
        let event = try await findOrCreate(in: context, matching: predicate)

        event.key = key

        let yearString = String(key.prefix(4))
        if let year = Int(yearString) {
            event.year = NSNumber(value: year)
        }

        return event
    }

    /**
     Insert an Event with values from a TBAKit Event model in to the managed object context.

     This method manages deleting orphaned Webcasts.

     - Parameter model: The TBAKit Event representation to set values from.

     - Parameter context: The NSManagedContext to insert the Event in to.

     - Returns: The inserted Event.
     */
    @discardableResult
    public static func insert(_ model: APIEvent, in context: NSManagedObjectContext) async throws -> TBAEvent {
        let predicate = TBAEvent.predicate(key: model.key)
        let event = try await findOrCreate(in: context, matching: predicate)

        event.address = model.address
        event.city = model.city
        event.country = model.country

        if let district = model.district {
            event.district = District.insert(district, in: context)
        } else {
            event.district = nil
        }

        // Note to Zach: We were trying to see if we could use an AsyncSequence here
        // so that we could still use map/filter. It feels like there's some way
        // to make this sort of thing happen, I'm just unsure how
        var divisions: Set<TBAEvent> = Set()
        for key in model.divisionKeys {
            divisions.insert(try await TBAEvent.insert(key, in: context))
        }
        event.divisions = !divisions.isEmpty ? divisions : nil

        event.endDate = model.endDate
        event.eventCode = model.eventCode
        event.eventType = NSNumber(value: model.eventType)
        event.eventTypeString = model.eventTypeString
        event.firstEventID = model.firstEventID
        event.firstEventCode = model.firstEventCode
        event.gmapsPlaceID = model.gmapsPlaceID
        event.gmapsURL = model.gmapsURL

        event.key = model.key

        if let lat = model.lat {
            event.lat = NSNumber(value: lat)
        } else {
            event.lat = nil
        }
        if let lng = model.lng {
            event.lng = NSNumber(value: lng)
        } else {
            event.lng = nil
        }

        event.locationName = model.locationName
        event.name = model.name

        if let parentEventKey = model.parentEventKey {
            event.parentEvent = try await TBAEvent.insert(parentEventKey, in: context)
        } else {
            event.parentEvent = nil
        }

        if let playoffType = model.playoffType {
            event.playoffType = NSNumber(value: playoffType)
        } else {
            event.playoffType = nil
        }
        event.playoffTypeString = model.playoffTypeString

        event.postalCode = model.postalCode
        event.shortName = model.shortName
        event.startDate = model.startDate
        event.stateProv = model.stateProv
        event.timezone = model.timezone

        try await event.insert(model.webcasts ?? [])

        event.website = model.website

        if let week = model.week {
            event.week = NSNumber(value: week)
        } else {
            event.week = nil
        }

        event.year = NSNumber(value: model.year)

        /*
        event.hybridType = calculateHybridType(eventType: model.eventType,
                                               startDate: model.startDate,
                                               district: model.district)
        */

        return event
    }

    /*
    /**
     Insert Event Alliances with values from a TBAKit Alliance models in to the managed object context.

     This method will manage setting up an Event Alliance's relationship to an Event and the deletion of oprhaned Event Alliances on the Event.

     - Parameter alliances: The TBAKit Alliance representations to set values from.
     */
    public func insert(_ alliances: [TBAAlliance]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.alliancesRaw), newValues: alliances.map {
            return EventAlliance.insert($0, eventKey: key, in: managedObjectContext)
        })
    }

    /**
     Insert Awards with values from a TBAKit Award models in to the managed object context.

     This method will manage setting up an Award's relationship to an Event and the deletion of oprhaned Awards on the Event.

     - Parameter awards: The TBAKit Award representations to set values from.
     */
    public func insert(_ awards: [TBAAward]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.awardsRaw), newValues: awards.map({
            return Award.insert($0, in: managedObjectContext)
        }))
    }

    /**
     Insert Awards for a given Team key with values from a TBAKit Award models in to the managed object context.

     This method will manage setting up an Award's relationship to an Event and the deletion of oprhaned Awards for a Team key on the Event.

     - Parameter awards: The TBAKit Award representations to set values from.

     - Parameter teamKey: The key for the Team the Awards belong to.
     */
    public func insert(_ awards: [TBAAward], teamKey: String) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        let teamPredicate = Award.teamPredicate(teamKey: teamKey)
        let oldAwards = self.awards.filter {
            return teamPredicate.evaluate(with: $0)
        }

        // Insert new Awards
        let awards = awards.map({ (model: TBAAward) -> Award in
            let a = Award.insert(model, in: managedObjectContext)
            addToAwardsRaw(a)
            return a
        })

        // Delete orphaned Awards for this Event/TeamKey
        Set(oldAwards).subtracting(Set(awards)).forEach {
            managedObjectContext.delete($0)
        }
    }

    /**
     Insert an EventInsight with values from TBAKit EventInsight model in to the managed object context.

     This method will manage setting up an EventInsight's relationship to an Event.

     - Parameter insights: The TBAKit EventInsights representations to set values from.
     */
    public func insert(_ insights: TBAEventInsights) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        let key = self.key
        updateToOneRelationship(relationship: #keyPath(Event.insightsRaw), newValue: insights, newObject: {
            return EventInsights.insert($0, eventKey: key, in: managedObjectContext)
        })
    }

    /**
     Insert Matches with values from TBAKit Match models in to the managed object context.

     This method will manage setting up a Match's relationship to an Event and the deletion of oprhaned Matches on the Event.

     - Parameter matches: The TBAKit Match representations to set values from.
     */
    public func insert(_ matches: [TBAMatch]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.matchesRaw), newValues: matches.map({
            return Match.insert($0, in: managedObjectContext)
        }))
    }

    /**
     Insert Rankings with values from TBAKit Event Ranking models in to the managed object context.

     This method manages setting up an Event's relationship to Rankings.

     - Parameter rankings: The TBAKit Event Ranking representations to set values from.

     - Parameter sortOrderInfo: The TBA EventRankingSortOrder representations for this Ranking info

     - Parameter extraStatsInfo: The TBA EventRankingSortOrder representations for this Ranking info
     */
    public func insert(_ rankings: [TBAEventRanking], sortOrderInfo: [TBAEventRankingSortOrder]?, extraStatsInfo: [TBAEventRankingSortOrder]?) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.rankingsRaw), newValues: rankings.map({
            return EventRanking.insert($0, sortOrderInfo: sortOrderInfo, extraStatsInfo: extraStatsInfo, eventKey: key, in: managedObjectContext)
        }))
    }

    /**
     Insert EventTeamStats with values from a TBAKit Stat models in to the managed object context.

     This method manages setting up an Event's relationship to an EventTeamStats as well as deleting orphaned EventTeamStats

     - Parameter stats: The TBAKit Stat representation to set values from.
     */
    public func insert(_ stats: [TBAStat]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(Event.statsRaw), newValues: stats.map({
            return EventTeamStat.insert($0, eventKey: key, in: managedObjectContext)
        }))
    }

    /**
     Insert an Event Status with values from a TBAKit Event Status model in to the managed object context.

     This method manages setting up an Event's relationship to an Event Status, as well as setting up an EventStatusQual's Ranking's relationship to the Event

     - Parameter status: The TBAKit Event Status representation to set values from.
     */
    public func insert(_ status: TBAEventStatus) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        let status = EventStatus.insert(status, in: managedObjectContext)
        status.qual?.ranking?.setEvent(event: self)

        addToStatusesRaw(status)
    }

    /**
     Insert Teams with values from TBAKit Team models in to the managed object context.

     This method manages setting up an Event's relationship to Teams.

     - Parameter teams: The TBAKit Team representations to set values from.
     */
    public func insert(_ teams: [TBATeam]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.teamsRaw = NSSet(array: teams.map({
            return Team.insert($0, in: managedObjectContext)
        }))
    }
    */

    /**
     Insert Webcasts with values from TBAKit Webcast models in to the managed object context.

     This method manages setting up an Event's relationship to Webcasts and deleting orphaned Webcasts.

     - Parameter webcasts: The TBAKit Webcast representations to set values from.
     */
    public func insert(_ webcasts: [APIWebcast]) async throws {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        var wcs: [TBAWebcast] = []
        // TODO: Async sequence
        for webcast in webcasts {
            wcs.append(try await TBAWebcast.insert(webcast, in: managedObjectContext))
        }

        try await updateToManyRelationship(relationship: #keyPath(TBAEvent.webcasts), newValues: wcs)
    }

    /// Event's shouldn't really be deleted, but sometimes they can be
    public override func prepareForDeletion() {
        super.prepareForDeletion()

        webcasts.forEach {
            if $0.events.onlyObject(self) {
                // Webcast will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.events.remove(self)
            }
        }
    }

}

// extension Event: Dateable, Locatable, Surfable {}

extension TBAEvent {

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(TBAEvent.key), key)
    }

    /*
    public static func districtPredicate(districtKey: String) -> NSPredicate {
        return NSPredicate(format: "%K.%K == %@",
                           #keyPath(Event.districtRaw), #keyPath(District.keyRaw), districtKey)
    }

    public static func champsYearPredicate(key: String, year: Int) -> NSPredicate {
        // 2017 and onward - handle multiple CMPs
        let yearPredicate = Event.yearPredicate(year: year)
        let predicate = NSPredicate(format: "(%K == %ld || %K == %ld) && (%K == %@ || %K == %@)",
                                    #keyPath(Event.eventTypeRaw), EventType.championshipFinals.rawValue,
                                    #keyPath(Event.eventTypeRaw), EventType.championshipDivision.rawValue,
                                    #keyPath(Event.keyRaw), key,
                                    #keyPath(Event.parentEventRaw.keyRaw), key)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, predicate])
    }

    public static func eventTypeYearPredicate(eventType: EventType, year: Int) -> NSPredicate {
        let yearPredicate = Event.yearPredicate(year: year)
        let predicate = NSPredicate(format: "%K == %ld",
                                    #keyPath(Event.eventTypeRaw), eventType.rawValue)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, predicate])
    }

    public static func offseasonYearPredicate(startDate: Date, endDate: Date, year: Int) -> NSPredicate {
        let yearPredicate = Event.yearPredicate(year: year)

        // Conversion stuff, since Core Data still uses NSDate's
        let firstDayOfMonth = NSDate(timeIntervalSince1970: startDate.startOfMonth().timeIntervalSince1970)
        let lastDayOfMonth = NSDate(timeIntervalSince1970: endDate.endOfMonth().timeIntervalSince1970)
        let predicate = NSPredicate(format: "%K == %ld && (%K >= %@) AND (%K <= %@)",
                                    #keyPath(Event.eventTypeRaw), EventType.offseason.rawValue,
                                    #keyPath(Event.startDateRaw), firstDayOfMonth,
                                    #keyPath(Event.endDateRaw), lastDayOfMonth)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, predicate])
    }

    public static func teamPredicate(teamKey: String) -> NSPredicate {
        return NSPredicate(format: "SUBQUERY(%K, $t, $t.%K == %@).@count > 0",
                           #keyPath(Event.teamsRaw), #keyPath(Team.keyRaw), teamKey)
    }

    public static func teamYearPredicate(teamKey: String, year: Int) -> NSPredicate {
        let teamPredicate = Event.teamPredicate(teamKey: teamKey)
        let yearPredicate = Event.yearPredicate(year: year)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [teamPredicate, yearPredicate])
    }

    public static func teamYearNonePredicate(teamKey: String) -> NSPredicate {
        let teamPredicate = Event.teamPredicate(teamKey: teamKey)
        let yearPredicate = Event.yearPredicate(year: -1)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [teamPredicate, yearPredicate])
    }

    public static func unplayedEventPredicate(date: Date, year: Int) -> NSPredicate {
        let yearPredicate = Event.yearPredicate(year: year)

        let coreDataDate = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
        let beforeEndDatePredicate = NSPredicate(format: "%K >= %@ && %K != %ld",
                                                 #keyPath(Event.endDateRaw), coreDataDate,
                                                 #keyPath(Event.eventTypeRaw), EventType.championshipDivision.rawValue)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, beforeEndDatePredicate])
    }

    public static func weekYearPredicate(week: Int, year: Int) -> NSPredicate {
        let yearPredicate = Event.yearPredicate(year: year)
        // Event has a week - filter based on the week
        let weekPredicate = NSPredicate(format: "%K == %ld",
                                        #keyPath(Event.weekRaw), week)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, weekPredicate])
    }

    public static func yearPredicate(year: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %ld", #keyPath(Event.yearRaw), year)
    }

    public static func unknownYearPredicate(year: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %ld && NOT (%K IN %@)",
                           #keyPath(Event.yearRaw), year,
                           #keyPath(Event.eventTypeRaw), EventType.allCases.map { $0.rawValue })
    }

    public static func nonePredicate() -> NSPredicate {
        return NSPredicate(format: "%K == -1", #keyPath(Event.yearRaw))
    }

    public static func sortDescriptors() -> [NSSortDescriptor] {
        return [Event.startDateSortDescriptor(), Event.nameSortDescriptor()]
    }

    public static func endDateSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Event.endDateRaw), ascending: true)
    }

    public static func hybridTypeSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Event.hybridType), ascending: true)
    }

    public static func nameSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Event.nameRaw), ascending: true)
    }

    public static func startDateSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Event.startDateRaw), ascending: true)
    }

    public static func weekSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Event.weekRaw), ascending: true)
    }

    public static func hybridTypeKeyPath() -> String {
        return #keyPath(Event.hybridType)
    }

    public static func weekKeyPath() -> String {
        return #keyPath(Event.weekRaw)
    }

    /**
     Returns an NSPredicate for full Event objects - aka, they have all required API fields.
     This includes endDate, eventCode, eventType, key, name, startDate, year
     */
    public static func populatedEventsPredicate() -> NSPredicate {
        var keys = [#keyPath(Event.endDateRaw),
                    #keyPath(Event.eventCodeRaw),
                    #keyPath(Event.eventTypeRaw),
                    #keyPath(Event.keyRaw),
                    #keyPath(Event.nameRaw),
                    #keyPath(Event.startDateRaw),
                    #keyPath(Event.yearRaw)]
        let format = keys.map {
            return String("\($0) != nil")
        }.joined(separator: " && ")
        return NSPredicate(format: format)
    }

    // An array of events that are used to represent their corresponding week in the Week selector
    // We need a full object as opposed to a number because of CMP, off-season, etc.
    // TODO: Convert this to a data model that uses a Core Data model for init but isn't a Core Data model
    public static func weekEvents(for year: Int, in managedObjectContext: NSManagedObjectContext) -> [Event] {
        let events = Event.fetch(in: managedObjectContext) { (fetchRequest) in
            // Filter out CMP divisions - we don't want them below for our weeks calculation
            // Only fetch events with values for `eventType` so we can force-unwrap that value
            let predicate = NSPredicate(format: "%K == %ld && %K != %ld",
                                        #keyPath(Event.yearRaw), year,
                                        #keyPath(Event.eventTypeRaw), EventType.championshipDivision.rawValue)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, Event.populatedEventsPredicate()])
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(Event.weekRaw), ascending: true),
                NSSortDescriptor(key: #keyPath(Event.eventTypeRaw), ascending: true),
                NSSortDescriptor(key: #keyPath(Event.endDateRaw), ascending: true)
            ]
        }

        // Take one event for each week(type) to use for our weekEvents array
        // ex: one Preseason, one Week 1, one Week 2..., one CMP #1, one CMP #2, one Offseason for each month
        // Jesus, take the wheel
        var handledWeeks: Set<Int> = []
        var handledTypes: Set<EventType?> = []
        var handledOffseasonMonths: Set<String> = []
        return Array(events.compactMap({ (event) -> Event? in
            guard let eventType = event.eventType else {
                // Special case to handle unknown events - group all unknown event types together
                if handledTypes.contains(nil) {
                    return nil
                }
                handledTypes.insert(nil)
                return event
            }

            if let week = event.week {
                // Make sure each week only shows up once
                if handledWeeks.contains(week) {
                    return nil
                }
                handledWeeks.insert(week)
                return event
            } else if eventType == .championshipFinals {
                // Always add all CMP finals
                return event
            } else if eventType == .offseason {
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

    // hybridType is used a mechanism for sorting Events properly in fetch result controllers... they use a variety
    // of event data to kinda "move around" events in our data model to get groups/order right. Note - hybrid type
    // is ONLY safe to sort by for events within the same year. Sorting by hybrid type for events across years will
    // put events together roughly by their types, but not necessairly their true sorts (see Comparable for a true sort)
    internal static func calculateHybridType(eventType: Int, startDate: Date?, district: TBADistrict?) -> String {
        let isDistrictChampionshipEvent = (eventType == EventType.districtChampionshipDivision.rawValue || eventType == EventType.districtChampionship.rawValue)
        // Group districts together, group district CMPs together
        if isDistrictChampionshipEvent {
            // Due to how DCMP divisions come *after* everything else if sorted by default
            // This is a bit of a hack to get them to show up before DCMPs
            // Future-proofing - group DCMP divisions together based on district
            if eventType == EventType.districtChampionshipDivision.rawValue, let district = district {
                return "\(EventType.districtChampionship.rawValue)..\(district.abbreviation).dcmpd"
            }
            return "\(eventType).dcmp"
        } else if let district = district, !isDistrictChampionshipEvent {
            return "\(eventType).\(district.abbreviation)"
        } else if eventType == EventType.offseason.rawValue, let startDate = startDate {
            // Group offseason events together by month
            let month = UInt8(Calendar.current.component(.month, from: startDate))
            // Pad our month with a leading `0` - this is so we can have "99.9" < "99.11"
            // (September Offseason to be sorted before November Offseason). Swift will compare
            // each character's hex value one-by-one, which means we'll fail at "9" < "1".
            let monthString = String(format: "%02d", month)
            return "\(eventType).\(monthString)"
        }
        return "\(eventType)"
    }
    */

}

/*
extension Event: Comparable {

    // MARK: Comparable

    // In order... Preseason, Week 1, Week 2, ..., Week 7, CMP, Offseason, Unlabeled
    // (type: 100, week: nil) < (type: 0, week: 1)
    // (type: 99, week: nil) < (type: -1, week: nil)

    public static func <(lhs: Event, rhs: Event) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }

        guard let lhsType = lhs.eventType, let rhsType = rhs.eventType else {
            return lhs.key < rhs.key // Fallback to comparing key strings if we don't have the event type
        }

        // Preseason events should always come first
        if lhs.isPreseason || rhs.isPreseason {
            // Preseason, being 100, has the highest event type. So even though this seems backwards... it's not
            if lhs.isPreseason && rhs.isPreseason, let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate {
                return lhsStartDate < rhsStartDate
            }
            return lhsType > rhsType
        }
        // Unlabeled events go at the very end no matter what
        if lhs.isUnlabeled || rhs.isUnlabeled {
            // Same as preseason - unlabeled events are the lowest possible number so even though this line seems backwards it's not
            if lhs.isUnlabeled && rhs.isUnlabeled, let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate {
                return lhsStartDate < rhsStartDate
            }
            return lhsType > rhsType
        }
        // Offseason events come after everything besides unlabeled
        if lhs.isOffseason || rhs.isOffseason {
            // We've already handled preseason (100) so now we can assume offseason's (99) will always be the highest type
            if lhs.isOffseason && rhs.isOffseason, let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate {
                return lhsStartDate < rhsStartDate
            }
            return lhsType < rhsType
        }
        // Throw Festival of Champions at the end, since it's the last event
        if lhs.isFoC || rhs.isFoC {
            if lhs.isFoC && rhs.isFoC, let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate {
                return lhsStartDate < rhsStartDate
            }
            return lhsType < rhsType
        }
        // CMP finals come after everything besides offseason, unlabeled
        if lhs.isChampionshipFinals || rhs.isChampionshipFinals {
            if lhs.isChampionshipFinals && rhs.isChampionshipFinals, let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate {
                return lhsStartDate < rhsStartDate
            }
            // Make sure we handle that districtCMPDivision case
            if lhs.isDistrictChampionshipDivision || rhs.isDistrictChampionshipDivision {
                return lhsType > rhsType
            }
            return lhsType < rhsType
        }
        // CMP divisions are next
        if lhs.isChampionshipDivision || rhs.isChampionshipDivision {
            if lhs.isChampionshipDivision && rhs.isChampionshipDivision, let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate {
                return lhsStartDate < rhsStartDate
            }
            // Make sure we handle that districtCMPDivision case
            if lhs.isDistrictChampionshipDivision || rhs.isDistrictChampionshipDivision {
                return lhsType > rhsType
            }
            return lhsType < rhsType
        }
        // EVERYTHING ELSE (districts, regionals, DCMPs, DCMP divisions) has weeks. This is just an easy sort... which event has a first week
        // Only weird thing is how we're sorting events that have the same weeks. It goes...
        // Regional < District < DCMP Division < DCMP
        if let lhsWeek = lhs.week, let rhsWeek = rhs.week {
            if lhsWeek == rhsWeek {
                // Make sure we handle the weird case of district championship divisions being a higher number than DCMPs
                if lhs.isDistrictChampionshipEvent && rhs.isDistrictChampionshipEvent {
                    if let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate {
                        return lhsStartDate < rhsStartDate
                    }
                    return lhsType > rhsType
                }
                if let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate {
                    return lhsStartDate < rhsStartDate
                }
                return lhsType < rhsType
            }
            return lhsWeek < rhsWeek
        }
        return false
    }

}

extension Event: MyTBASubscribable {

    public var modelKey: String {
        return key
    }

    public var modelType: MyTBAModelType {
        return .event
    }

    public static var notificationTypes: [NotificationType] {
        return [
            NotificationType.upcomingMatch,
            NotificationType.matchScore,
            NotificationType.levelStarting,
            NotificationType.allianceSelection,
            NotificationType.awards,
            NotificationType.scheduleUpdated,
            NotificationType.matchVideo
        ]
    }

}

extension Event: Searchable {

    public var searchAttributes: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: Event.entityName)

        attributeSet.displayName = safeNameYear
        attributeSet.alternateNames = [key, shortName, name].compactMap({ $0 }) // Queryable by short name or name
        // attributeSet.contentDescription = dateString

        // Date-related event stuff
        attributeSet.startDate = startDate
        attributeSet.endDate = endDate
        attributeSet.allDay = NSNumber(value: 1)

        // Location-related event stuff
        attributeSet.city = city
        attributeSet.country = country
        attributeSet.latitude = getValue(\Event.latRaw)
        attributeSet.longitude = getValue(\Event.lngRaw)
        attributeSet.namedLocation = locationName
        attributeSet.stateOrProvince = stateProv
        attributeSet.fullyFormattedAddress = address
        attributeSet.postalCode = postalCode

        return attributeSet
    }

    public var webURL: URL {
        return URL(string: "https://www.thebluealliance.com/event/\(key)")!
    }

}
*/
