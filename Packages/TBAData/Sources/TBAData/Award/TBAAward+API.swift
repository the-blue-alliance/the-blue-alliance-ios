import CoreData
import Foundation
import TBAKit

extension TBAAward: Managed {

    /**
     Insert an Award with values from a TBAKit Award model in to the managed object context.

     This method will manage the deletion of oprhaned Award Recipients.

     - Important: This method does not setup it's relationship to an Event.

     - Parameter model: The TBAKit Award representation to set values from.

     - Parameter context: The NSManagedContext to insert the Award in to.

     - Returns: The inserted Award.
     */
    public static func insert(_ model: APIAward, in context: NSManagedObjectContext) throws -> TBAAward {
        let predicate = NSPredicate(format: "%K == %ld && %K == %ld && %K == %@",
                                    #keyPath(TBAAward.awardType), model.awardType,
                                    #keyPath(TBAAward.year), model.year,
                                    #keyPath(TBAAward.event.key), model.eventKey)

        return try findOrCreate(in: context, matching: predicate) { (award) in
            award.name = model.name
            award.awardType = NSNumber(value: model.awardType)
            award.year = NSNumber(value: model.year)
            // award.event = try TBAEvent.insert(model.eventKey, in: context)

            /* TODO: Add this back in
            let recipients = try model.recipients.asyncMap {
                return await TBAAwardRecipient.insert($0, in: context)
            }

            award.updateToManyRelationship(relationship: #keyPath(TBAAward.recipients), newValues: recipients)
            */
        }
    }

    override public func prepareForDeletion() {
        super.prepareForDeletion()

        recipients?.forEach {
            guard let recipient = $0 as? TBAAwardRecipient else {
                return
            }
            if let awards = recipient.awards {
                if awards.onlyObject(self) {
                    // Recipient will become an orphan - delete
                    managedObjectContext?.delete(recipient)
                } else {
                    recipient.removeFromAwards(self)
                }
            } else {
                // No awards - good for deletion
                managedObjectContext?.delete(recipient)
            }
        }
    }

}

extension TBAAward {

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(TBAAward.event.key), eventKey)
    }

    public static func teamPredicate(teamKey: String) -> NSPredicate {
        return NSPredicate(format: "ANY %K.%K == %@",
                           #keyPath(TBAAward.recipients), #keyPath(TBAAwardRecipient.team.key), teamKey)
    }

    public static func teamEventPredicate(teamKey: String, eventKey: String) -> NSPredicate {
        let teamPredicate = TBAAward.teamPredicate(teamKey: teamKey)
        let eventPredicate = TBAAward.eventPredicate(eventKey: eventKey)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [eventPredicate, teamPredicate])
    }

    public static func typeSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(TBAAward.awardType), ascending: true)
    }

}

extension TBAAward: Orphanable {

    public var isOrphaned: Bool {
        return event == nil
    }

}
