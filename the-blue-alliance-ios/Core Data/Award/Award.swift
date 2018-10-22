import CoreData
import Foundation
import TBAKit

extension Award: Managed {

    @discardableResult
    static func insert(_ model: TBAAward, event contextEvent: Event, in context: NSManagedObjectContext) -> Award {
        let event = context.object(with: contextEvent.objectID) as! Event
        let predicate = NSPredicate(format: "%K == %@ && %K == %@ && %K == %@",
                                    #keyPath(Award.awardType), model.awardType as NSNumber,
                                    #keyPath(Award.year), model.year as NSNumber,
                                    #keyPath(Award.event.key), model.eventKey)
        return findOrCreate(in: context, matching: predicate) { (award) in
            // Required: awardType, event, name, year, recipients
            award.name = model.name
            award.event = event
            award.awardType = model.awardType as NSNumber
            award.year = model.year as NSNumber

            let recipients = model.recipients.map({ (recipient) -> AwardRecipient in
                return AwardRecipient.insert(recipient, award: award, in: context)
            })
            updateToManyRelationship(relationship: &award.recipients, newValues: recipients, matchingOrphans: {
                return $0.awards == Set([award]) as NSSet
            }, in: context)
        }
    }

}
