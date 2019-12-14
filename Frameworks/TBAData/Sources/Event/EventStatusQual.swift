import CoreData
import Foundation
import TBAKit

@objc(EventStatusQual)
public class EventStatusQual: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusQual> {
        return NSFetchRequest<EventStatusQual>(entityName: EventStatusQual.entityName)
    }

    public var numTeams: Int? {
        return numTeamsNumber?.intValue
    }

    @NSManaged private var numTeamsNumber: NSNumber?
    @NSManaged private var status: String?

    @NSManaged internal var eventStatus: EventStatus?
    @NSManaged internal var ranking: EventRanking?

}

extension EventStatusQual: Managed {

    public static func insert(_ model: TBAEventStatusQual, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusQual {
        let predicate = NSPredicate(format: "(%K.%K.%K == %@ AND %K.%K.%K == %@) OR (%K.%K.%K == %@ AND %K.%K.%K == %@)",
                                    #keyPath(EventStatusQual.ranking), EventRanking.eventKeyPath(), Event.keyPath(), eventKey,
                                    #keyPath(EventStatusQual.ranking), EventRanking.teamKeyPath(), #keyPath(Team.keyString), teamKey,
                                    EventStatusQual.eventStatusKeyPath(), EventStatus.eventKeyPath(), Event.keyPath(), eventKey,
                                    EventStatusQual.eventStatusKeyPath(), EventStatus.teamKeyPath(), #keyPath(Team.keyString), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (eventStatusQual) in
            if let numTeams = model.numTeams {
                eventStatusQual.numTeamsNumber = NSNumber(value: numTeams)
            } else {
                eventStatusQual.numTeamsNumber = nil
            }
            eventStatusQual.status = model.status

            eventStatusQual.updateToOneRelationship(relationship: #keyPath(EventStatusQual.ranking), newValue: model.ranking) {
                return EventRanking.insert($0, sortOrderInfo: model.sortOrder, extraStatsInfo: nil, eventKey: eventKey, in: context)
            }
        })
    }

}

extension EventStatusQual {

    public static func eventStatusKeyPath() -> String {
        return #keyPath(EventStatusQual.eventStatus)
    }

}

extension EventStatusQual: Orphanable {

    public var isOrphaned: Bool {
        // EventStatusQual is an orphan if it's not attached to a Ranking or an EventStatus
        let hasRanking = (ranking != nil)
        let hasStatus = (eventStatus != nil)
        return !hasRanking && !hasStatus
    }

}
