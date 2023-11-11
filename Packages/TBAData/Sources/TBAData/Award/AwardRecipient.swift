import CoreData
import Foundation
import TBAKit

extension AwardRecipient {

    public var awardee: String? {
        return getValue(\AwardRecipient.awardeeRaw)
    }

    public var awards: [Award] {
        guard let awardsMany = getValue(\AwardRecipient.awardsRaw),
            let awards = awardsMany.allObjects as? [Award] else {
                fatalError("Save AwardRecipient before accessing awards")
        }
        return awards
    }

    public var team: Team? {
        return getValue(\AwardRecipient.teamRaw)
    }

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

@objc(AwardRecipient)
public class AwardRecipient: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AwardRecipient> {
        return NSFetchRequest<AwardRecipient>(entityName: AwardRecipient.entityName)
    }

    @NSManaged var awardeeRaw: String?
    @NSManaged var awardsRaw: NSSet?
    @NSManaged var teamRaw: Team?

}

// MARK: Generated accessors for awardsRaw
extension AwardRecipient {

    @objc(addAwardsRawObject:)
    @NSManaged func addToAwardsRaw(_ value: Award)

    @objc(removeAwardsRawObject:)
    @NSManaged func removeFromAwardsRaw(_ value: Award)

    @objc(addAwardsRaw:)
    @NSManaged func addToAwardsRaw(_ values: NSSet)

    @objc(removeAwardsRaw:)
    @NSManaged func removeFromAwardsRaw(_ values: NSSet)

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
                                   #keyPath(AwardRecipient.awardeeRaw), awardee,
                                   #keyPath(AwardRecipient.teamRaw.keyRaw), teamKey)
            } else if let teamKey = model.teamKey {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(AwardRecipient.teamRaw.keyRaw), teamKey)
            } else if let awardee = model.awardee {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(AwardRecipient.awardeeRaw), awardee)
            }
            return NSPredicate(format: "%K == nil AND %K == nil",
                               #keyPath(AwardRecipient.awardeeRaw),
                               #keyPath(AwardRecipient.teamRaw.keyRaw))
        }

        return findOrCreate(in: context, matching: predicate) { (awardRecipient) in
            if let teamKey = model.teamKey {
                awardRecipient.teamRaw = Team.insert(teamKey, in: context)
            } else {
                awardRecipient.teamRaw = nil
            }
            awardRecipient.awardeeRaw = model.awardee
        }
    }

}

extension AwardRecipient: Orphanable {

    public var isOrphaned: Bool {
        return awards.count == 0
    }

}
