import CoreData
import Foundation
import TBAKit
import TBAUtils

@objc(Award)
public class Award: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Award> {
        return NSFetchRequest<Award>(entityName: Award.entityName)
    }

    public var awardType: Int {
        guard let awardType = awardTypeNumber?.intValue else {
            fatalError("Save Award before accessing awardType")
        }
        return awardType
    }

    public var name: String {
        guard let name = nameString else {
            fatalError("Save Award before accessing name")
        }
        return name
    }

    public var year: Int {
        guard let year = yearNumber?.intValue else {
            fatalError("Save Award before accessing year")
        }
        return year
    }

    @NSManaged private var awardTypeNumber: NSNumber?
    @NSManaged private var nameString: String?
    @NSManaged private var yearNumber: NSNumber?

    public var event: Event {
        guard let event = eventOne else {
            fatalError("Save Award before accessing event")
        }
        return event
    }

    public var recipients: [AwardRecipient] {
        guard let recipientsMany = recipientsMany,
            let recipients = recipientsMany.allObjects as? [AwardRecipient] else {
                fatalError("Save Award before accessing recipients")
        }
        return recipients
    }

    @NSManaged private var eventOne: Event?
    @NSManaged private var recipientsMany: NSSet?

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
                                    #keyPath(Award.awardTypeNumber), model.awardType,
                                    #keyPath(Award.yearNumber), model.year,
                                    #keyPath(Award.eventOne.keyString), model.eventKey)

        return findOrCreate(in: context, matching: predicate) { (award) in
            // Required: awardType, event, name, year, recipients
            award.nameString = model.name
            award.awardTypeNumber = NSNumber(value: model.awardType)
            award.yearNumber = NSNumber(value: model.year)
            award.eventOne = Event.insert(model.eventKey, in: context)

            award.updateToManyRelationship(relationship: #keyPath(Award.recipientsMany), newValues: model.recipients.map {
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
                $0.removeFromAwardsMany(self)
            }
        }
    }

}

extension Award {

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Award.eventOne.keyString), eventKey)
    }

    public static func teamPredicate(teamKey: String) -> NSPredicate {
        return NSPredicate(format: "(ANY %K == %@)",
                           #keyPath(Award.recipientsMany.team.keyString), teamKey)
    }

    public static func teamEventPredicate(team: Team, event: Event) -> NSPredicate {
        let teamPredicate = Award.teamPredicate(teamKey: team.key)
        let eventPredicate = Award.eventPredicate(eventKey: event.key)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [eventPredicate, teamPredicate])
    }

    public static func typeSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Award.awardTypeNumber), ascending: true)
    }

}

extension Award: Orphanable {

    public var isOrphaned: Bool {
        return eventOne == nil
    }

}
