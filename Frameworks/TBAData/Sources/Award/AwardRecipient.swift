import CoreData
import Foundation
import TBAKit

@objc(AwardRecipient)
public class AwardRecipient: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AwardRecipient> {
        return NSFetchRequest<AwardRecipient>(entityName: "AwardRecipient")
    }

    @NSManaged public fileprivate(set) var awardee: String?
    @NSManaged public fileprivate(set) var awards: NSSet
    @NSManaged public fileprivate(set) var team: Team?

}

// MARK: Generated accessors for awards
extension AwardRecipient {

    @objc(addAwardsObject:)
    @NSManaged private func addToAwards(_ value: Award)

    @objc(removeAwardsObject:)
    @NSManaged internal func removeFromAwards(_ value: Award)

    @objc(addAwards:)
    @NSManaged private func addToAwards(_ values: NSSet)

    @objc(removeAwards:)
    @NSManaged private func removeFromAwards(_ values: NSSet)

}

extension AwardRecipient {

    /**
     Insert an Award Recipient with values from a TBAKit Award Recipient model in to the managed object context.

     Award Recipients will never be 'updated'. They can be deleted from Award, but the predicates for this
     won't allow matching an existing Award Recipient for updates.

     - Important: This method does not setup it's relationship to an Award.

     - Parameter model: The TBAKit Award Recipient representation to set values from.

     - Parameter context: The NSManagedContext to insert the Award Recipient in to.

     - Returns: The inserted Award Recipient.
     */
    public static func insert(_ model: TBAAwardRecipient, in context: NSManagedObjectContext) -> AwardRecipient {
        var predicate: NSPredicate {
            if let awardee = model.awardee, let teamKey = model.teamKey {
                return NSPredicate(format: "%K == %@ AND %K == %@",
                                   #keyPath(AwardRecipient.awardee), awardee,
                                   #keyPath(AwardRecipient.team.key), teamKey)
            } else if let teamKey = model.teamKey {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(AwardRecipient.team.key), teamKey)
            } else if let awardee = model.awardee {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(AwardRecipient.awardee), awardee)
            } else {
                return NSPredicate(format: "%K == nil AND %K == nil",
                                   #keyPath(AwardRecipient.awardee),
                                   #keyPath(AwardRecipient.team.key))
            }
        }

        return findOrCreate(in: context, matching: predicate) { (awardRecipient) in
            awardRecipient.updateToOneRelationship(relationship: #keyPath(AwardRecipient.team), newValue: model.teamKey, newObject: {
                return Team.insert($0, in: context)
            })
            awardRecipient.awardee = model.awardee
        }
    }

}
