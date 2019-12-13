import CoreData
import Foundation
import TBAKit

@objc(EventStatusQual)
public class EventStatusQual: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusQual> {
        return NSFetchRequest<EventStatusQual>(entityName: "EventStatusQual")
    }

    @NSManaged public fileprivate(set) var numTeams: NSNumber?
    @NSManaged public fileprivate(set) var status: String?
    @NSManaged public internal(set) var eventStatus: EventStatus?
    @NSManaged public internal(set) var ranking: EventRanking?

}

extension EventStatusQual: Managed {

    public static func insert(_ model: TBAEventStatusQual, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusQual {
        let predicate = NSPredicate(format: "(%K == %@ AND %K == %@) OR (%K == %@ AND %K == %@)",
                                    #keyPath(EventStatusQual.ranking.event.key), eventKey,
                                    #keyPath(EventStatusQual.ranking.team.keyString), teamKey,
                                    #keyPath(EventStatusQual.eventStatus.event.key), eventKey,
                                    #keyPath(EventStatusQual.eventStatus.team.keyString), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (eventStatusQual) in
            eventStatusQual.numTeams = model.numTeams as NSNumber?
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
