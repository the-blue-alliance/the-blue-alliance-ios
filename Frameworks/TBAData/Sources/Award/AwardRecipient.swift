import CoreData
import Foundation
import TBAKit

@objc(AwardRecipient)
public class AwardRecipient: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AwardRecipient> {
        return NSFetchRequest<AwardRecipient>(entityName: AwardRecipient.entityName)
    }

    @NSManaged public private(set) var awardee: String?

    public var awards: [Award] {
        guard let awardsMany = awardsMany, let awards = awardsMany.allObjects as? [Award] else {
            fatalError("Save AwardRecipient before accessing awards")
        }
        return awards
    }

    @NSManaged private var awardsMany: NSSet?
    @NSManaged public private(set) var team: Team?

}

// MARK: Generated accessors for awardsMany
extension AwardRecipient {

    @objc(removeAwardsManyObject:)
    @NSManaged internal func removeFromAwardsMany(_ value: Award)

}

extension AwardRecipient: Managed {

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
                                   #keyPath(AwardRecipient.team.keyString), teamKey)
            } else if let teamKey = model.teamKey {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(AwardRecipient.team.keyString), teamKey)
            } else if let awardee = model.awardee {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(AwardRecipient.awardee), awardee)
            } else {
                return NSPredicate(format: "%K == nil AND %K == nil",
                                   #keyPath(AwardRecipient.awardee),
                                   #keyPath(AwardRecipient.team.keyString))
            }
        }

        return findOrCreate(in: context, matching: predicate) { (awardRecipient) in
            if let teamKey = model.teamKey {
                awardRecipient.team = Team.insert(teamKey, in: context)
            } else {
                awardRecipient.team = nil
            }
            awardRecipient.awardee = model.awardee
        }
    }

}

extension AwardRecipient {

    /**
     A sorted array of strings describing the award recipient.
     */
    public var awardText: [String] {
        var awardText: [String] = []
        if let team = team, let awardee = awardee {
            // Zachary Orr
            // Team 7332
            awardText.append(awardee)
            awardText.append(team.teamNumberNickname)
        } else if let team = team {
            // If we have a nickname for the team, add the team number beforehand, so the cell reads as...
            // Team 7332
            // The Rawrbotz
            if let nickname = team.nickname {
                awardText.append(team.teamNumberNickname)
                awardText.append(nickname)
            } else {
                awardText.append(team.teamNumberNickname)
            }
        } else if let awardee = awardee {
            awardText.append(awardee)
        } else {
            awardText.append("--")
        }
        return awardText
    }

}

extension AwardRecipient: Orphanable {

    public var isOrphaned: Bool {
        guard let awardsMany = awardsMany else {
            return true
        }
        return awardsMany.count == 0
    }

}
