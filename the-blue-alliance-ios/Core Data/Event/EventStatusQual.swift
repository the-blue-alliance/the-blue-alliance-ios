import Foundation
import CoreData
import TBAKit

extension EventStatusQual: Managed {

    static func insert(with model: TBAEventStatusQual, eventStatus: EventStatus, in context: NSManagedObjectContext) -> EventStatusQual {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(EventStatusQual.eventStatus), eventStatus)
        return findOrCreate(in: context, matching: predicate, configure: { (eventStatusQual) in
            eventStatusQual.eventStatus = eventStatus

            if let numTeams = model.numTeams {
                eventStatusQual.numTeams = NSNumber(value: numTeams)
            }
            eventStatusQual.status = model.status

            if let event = eventStatus.event, let ranking = model.ranking, let sortOrder = model.sortOrder {
                eventStatusQual.ranking = EventRanking.insert(with: ranking, for: event, for: sortOrder, in: context)
            }
        })
    }

}
