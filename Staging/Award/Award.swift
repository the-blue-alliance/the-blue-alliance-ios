import CoreData
import Foundation
import TBAKit
import TBAUtils

extension Award {

    public var awardType: Int {
        guard let awardType = getValue(\Award.awardTypeRaw)?.intValue else {
            fatalError("Save Award before accessing awardType")
        }
        return awardType
    }

    public var name: String {
        guard let name = getValue(\Award.nameRaw) else {
            fatalError("Save Award before accessing name")
        }
        return name
    }

    public var year: Int {
        guard let year = getValue(\Award.yearRaw)?.intValue else {
            fatalError("Save Award before accessing year")
        }
        return year
    }

    public var event: Event {
        guard let event = getValue(\Award.eventRaw) else {
            fatalError("Save Award before accessing event")
        }
        return event
    }

    public var recipients: [AwardRecipient] {
        guard let recipientsMany = getValue(\Award.recipientsRaw),
            let recipients = recipientsMany.allObjects as? [AwardRecipient] else {
                fatalError("Save Award before accessing recipients")
        }
        return recipients
    }
    
}

@objc(Award)
public class Award: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Award> {
        return NSFetchRequest<Award>(entityName: Award.entityName)
    }

    @NSManaged var awardTypeRaw: NSNumber?
    @NSManaged var nameRaw: String?
    @NSManaged var yearRaw: NSNumber?
    @NSManaged var eventRaw: Event?
    @NSManaged var recipientsRaw: NSSet?

}

// MARK: Generated accessors for recipientsRaw
extension Award {

    @objc(addRecipientsRawObject:)
    @NSManaged func addToRecipientsRaw(_ value: AwardRecipient)

    @objc(removeRecipientsRawObject:)
    @NSManaged func removeFromRecipientsRaw(_ value: AwardRecipient)

    @objc(addRecipientsRaw:)
    @NSManaged func addToRecipientsRaw(_ values: NSSet)

    @objc(removeRecipientsRaw:)
    @NSManaged func removeFromRecipientsRaw(_ values: NSSet)

}

extension Award: Managed {

    /**
     Insert an Award with values from a TBAKit Award model in to the managed object context.

     This method will manage the deletion of oprhaned Award Recipients.

     - Important: This method does not setup it's relationship to an Event.

     - Parameter model: The TBAKit Award representation to set values from.

     - Parameter context: The NSManagedContext to insert the Award in to.

     - Returns: The inserted Award.
     */
    public static func insert(_ model: TBAAward, in context: NSManagedObjectContext) -> Award {
        let predicate = NSPredicate(format: "%K == %ld && %K == %ld && %K == %@",
                                    #keyPath(Award.awardTypeRaw), model.awardType,
                                    #keyPath(Award.yearRaw), model.year,
                                    #keyPath(Award.eventRaw.keyRaw), model.eventKey)

        return findOrCreate(in: context, matching: predicate) { (award) in
            // Required: awardType, event, name, year, recipients
            award.nameRaw = model.name
            award.awardTypeRaw = NSNumber(value: model.awardType)
            award.yearRaw = NSNumber(value: model.year)
            award.eventRaw = Event.insert(model.eventKey, in: context)

            award.updateToManyRelationship(relationship: #keyPath(Award.recipientsRaw), newValues: model.recipients.map {
                return AwardRecipient.insert($0, in: context)
            })
        }
    }

    override public func prepareForDeletion() {
        super.prepareForDeletion()

        recipients.forEach {
            if $0.awards.onlyObject(self) {
                // Recipient will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.removeFromAwardsRaw(self)
            }
        }
    }

}

extension Award {

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Award.eventRaw.keyRaw), eventKey)
    }

    public static func teamPredicate(teamKey: String) -> NSPredicate {
        return NSPredicate(format: "ANY %K.%K == %@",
                           #keyPath(Award.recipientsRaw), #keyPath(AwardRecipient.teamRaw.keyRaw), teamKey)
    }

    public static func teamEventPredicate(teamKey: String, eventKey: String) -> NSPredicate {
        let teamPredicate = Award.teamPredicate(teamKey: teamKey)
        let eventPredicate = Award.eventPredicate(eventKey: eventKey)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [eventPredicate, teamPredicate])
    }

    public static func typeSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Award.awardTypeRaw), ascending: true)
    }

}

extension Award: Orphanable {

    public var isOrphaned: Bool {
        return eventRaw == nil
    }

}
