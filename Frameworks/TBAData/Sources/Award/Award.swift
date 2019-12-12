import CoreData
import Foundation
import TBAKit
import TBAUtils

@objc(Award)
public class Award: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Award> {
        return NSFetchRequest<Award>(entityName: "Award")
    }

    @NSManaged public fileprivate(set) var awardType: Int16
    @NSManaged public fileprivate(set) var name: String?
    @NSManaged public fileprivate(set) var year: Int16
    @NSManaged public fileprivate(set) var event: Event
    @NSManaged public fileprivate(set) var recipients: NSSet

}

extension Award {

    /**
     Insert an Award with values from a TBAKit Award model in to the managed object context.

     This method will manage the deletion of oprhaned Award Recipients.

     - Important: This method does not setup it's relationship to an Event.

     - Parameter model: The TBAKit Award representation to set values from.

     - Parameter context: The NSManagedContext to insert the Award in to.

     - Returns: The inserted Award.
     */
    public static func insert(_ model: TBAAward, in context: NSManagedObjectContext) -> Award {
        let predicate = NSPredicate(format: "%K == %@ && %K == %@ && %K == %@",
                                    #keyPath(Award.awardType), model.awardType as NSNumber,
                                    #keyPath(Award.year), model.year as NSNumber,
                                    #keyPath(Award.event.key), model.eventKey)

        return findOrCreate(in: context, matching: predicate) { (award) in
            // Required: awardType, event, name, year, recipients
            award.name = model.name
            award.awardType = Int16(model.awardType)
            award.year = Int16(model.year)

            award.updateToManyRelationship(relationship: #keyPath(Award.recipients), newValues: model.recipients.map({
                return AwardRecipient.insert($0, in: context)
            }))

            award.updateToOneRelationship(relationship: #keyPath(Award.event), newValue: model.eventKey) {
                return Event.insert($0, in: context)
            }
        }
    }

    override public func prepareForDeletion() {
        super.prepareForDeletion()

        (recipients.allObjects as? [AwardRecipient])?.forEach({
            if $0.awards.onlyObject(self) {
                // Recipient will become an orphan - delete
                managedObjectContext?.delete($0)
            } else {
                $0.removeFromAwards(self)
            }
        })
    }

}

extension Award: Managed {

    public var isOrphaned: Bool {
        return event == nil
    }

}
