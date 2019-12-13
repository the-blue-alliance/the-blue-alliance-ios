import CoreData
import Foundation
import TBAKit

@objc(EventStatusQual)
public class EventStatusQual: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusQual> {
        return NSFetchRequest<EventStatusQual>(entityName: "EventStatusQual")
    }

    public var numTeams: Int? {
        return numTeamsNumber?.intValue
    }

    @NSManaged private var numTeamsNumber: NSNumber?
    @NSManaged private var status: String?
    @NSManaged public internal(set) var eventStatus: EventStatus?
    @NSManaged public internal(set) var ranking: EventRanking?

}

extension EventStatusQual: Managed {

    public static func insert(_ model: TBAEventStatusQual, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusQual {
        let predicate = NSPredicate(format: "(%K == %@ AND %K == %@) OR (%K == %@ AND %K == %@)",
                                    #keyPath(EventStatusQual.ranking.eventOne.keyString), eventKey,
                                    #keyPath(EventStatusQual.ranking.teamOne.keyString), teamKey,
                                    #keyPath(EventStatusQual.eventStatus.eventOne.keyString), eventKey,
                                    #keyPath(EventStatusQual.eventStatus.teamOne.keyString), teamKey)

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

extension EventStatusQual: Orphanable {

    public var isOrphaned: Bool {
        // EventStatusQual is an orphan if it's not attached to a Ranking or an EventStatus
        let hasRanking = (ranking != nil)
        let hasStatus = (eventStatus != nil)
        return !hasRanking && !hasStatus
    }

}
