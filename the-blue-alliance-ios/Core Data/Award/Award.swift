import CoreData
import Foundation
import TBAKit

extension Award: Managed {

    private static func insert(_ model: TBAAward, in context: NSManagedObjectContext) -> Award {
        let predicate = NSPredicate(format: "%K == %@ && %K == %@ && %K == %@",
                                    #keyPath(Award.awardType), model.awardType as NSNumber,
                                    #keyPath(Award.year), model.year as NSNumber,
                                    #keyPath(Award.event.key), model.eventKey)
        return findOrCreate(in: context, matching: predicate) { (award) in
            // Required: awardType, event, name, year, recipients
            award.name = model.name
            award.awardType = model.awardType as NSNumber
            award.year = model.year as NSNumber

            updateToManyRelationship(relationship: &award.recipients, newValues: model.recipients.map({ (recipient) -> AwardRecipient in
                return AwardRecipient.insert(recipient, award: award, in: context)
            }), matchingOrphans: { (recipient: AwardRecipient) in
                // If an Award Recipient's only Award is this award, it's an orphan now
                return recipient.awards?.allObjects as? [Award] == [award]
            }, in: context)
        }
    }

    @discardableResult
    static func insert(_ awards: [TBAAward], event: Event, in context: NSManagedObjectContext) -> [Award] {
        let event = context.object(with: event.objectID) as! Event
        let awards = awards.map({
            return Award.insert($0, in: context)
        })
        updateToManyRelationship(relationship: &event.awards, newValues: awards, matchingOrphans: { _ in
            // Awards will never belong to more than one event, so this should always be true
            return true
        }, in: context)
        return awards
    }

    override public func prepareForDeletion() {
        super.prepareForDeletion()

        (recipients?.allObjects as? [AwardRecipient])?.forEach({
            if $0.awards == (Set([self]) as NSSet) {
                // Recipient will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.removeFromAwards(self)
            }
        })
    }

}
