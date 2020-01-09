import CoreData
import Foundation
import TBAKit

extension EventStatusQual {

    public var numTeams: Int? {
        return getValue(\EventStatusQual.numTeamsRaw)?.intValue
    }

    public var status: String? {
        return getValue(\EventStatusQual.statusRaw)
    }

    public var eventStatus: EventStatus? {
        return getValue(\EventStatusQual.eventStatusRaw)
    }

    public var ranking: EventRanking? {
        return getValue(\EventStatusQual.rankingRaw)
    }

}

@objc(EventStatusQual)
public class EventStatusQual: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventStatusQual> {
        return NSFetchRequest<EventStatusQual>(entityName: EventStatusQual.entityName)
    }

    @NSManaged var numTeamsRaw: NSNumber?
    @NSManaged var statusRaw: String?
    @NSManaged var eventStatusRaw: EventStatus?
    @NSManaged var rankingRaw: EventRanking?

}

extension EventStatusQual: Managed {

    public static func insert(_ model: TBAEventStatusQual, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusQual {
        let predicate = NSPredicate(format: "(%K == %@ AND %K == %@) OR (%K == %@ AND %K == %@)",
                                    #keyPath(EventStatusQual.rankingRaw.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventStatusQual.rankingRaw.teamRaw.keyRaw), teamKey,
                                    #keyPath(EventStatusQual.eventStatusRaw.eventRaw.keyRaw), eventKey,
                                    #keyPath(EventStatusQual.eventStatusRaw.teamRaw.keyRaw), teamKey)
        return findOrCreate(in: context, matching: predicate, configure: { (eventStatusQual) in
            if let numTeams = model.numTeams {
                eventStatusQual.numTeamsRaw = NSNumber(value: numTeams)
            } else {
                eventStatusQual.numTeamsRaw = nil
            }
            eventStatusQual.statusRaw = model.status

            eventStatusQual.updateToOneRelationship(relationship: #keyPath(EventStatusQual.rankingRaw), newValue: model.ranking) {
                return EventRanking.insert($0, sortOrderInfo: model.sortOrder, extraStatsInfo: nil, eventKey: eventKey, in: context)
            }
        })
    }

}

extension EventStatusQual: Orphanable {

    public var isOrphaned: Bool {
        // EventStatusQual is an orphan if it's not attached to a Ranking or an EventStatus
        let hasRanking = (rankingRaw != nil)
        let hasStatus = (eventStatusRaw != nil)
        return !hasRanking && !hasStatus
    }

}
