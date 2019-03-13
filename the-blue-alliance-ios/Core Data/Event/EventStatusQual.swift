import CoreData
import Foundation
import TBAKit

extension EventStatusQual: Managed {

    static func insert(_ model: TBAEventStatusQual, eventKey: String, teamKey: String, in context: NSManagedObjectContext) -> EventStatusQual {
        let predicate = NSPredicate(format: "(%K == %@ AND %K == %@) OR (%K == %@ AND %K == %@)",
                                    #keyPath(EventStatusQual.ranking.event.key), eventKey,
                                    #keyPath(EventStatusQual.ranking.teamKey.key), teamKey,
                                    #keyPath(EventStatusQual.eventStatus.event.key), eventKey,
                                    #keyPath(EventStatusQual.eventStatus.teamKey.key), teamKey)

        return findOrCreate(in: context, matching: predicate, configure: { (eventStatusQual) in
            eventStatusQual.numTeams = model.numTeams as NSNumber?
            eventStatusQual.status = model.status

            eventStatusQual.updateToOneRelationship(relationship: #keyPath(EventStatusQual.ranking), newValue: model.ranking) {
                return EventRanking.insert($0, sortOrderInfo: model.sortOrder, extraStatsInfo: nil, eventKey: eventKey, in: context)
            }
        })
    }

    var isOrphaned: Bool {
        // EventStatusQual is an orphan if it's not attached to a Ranking or an EventStatus
        let hasRanking = (ranking != nil)
        let hasStatus = (eventStatus != nil)
        return !hasRanking && !hasStatus
    }

}
