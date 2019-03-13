import CoreData
import Foundation
import TBAKit

extension AwardRecipient {

    /**
     A sorted array of strings describing the award recipient.
     */
    public var awardText: [String] {
        var awardText: [String] = []
        if let teamKey = teamKey, let awardee = awardee {
            awardText.append(awardee)
            awardText.append(teamKey.name)
        } else if let teamKey = teamKey {
            // If we have a nickname for the team, add the team number beforehand, so the cell reads as...
            // Team 7332
            // The Rawrbotz
            if let nickname = teamKey.team?.nickname {
                awardText.append("\(teamKey.name)")
                awardText.append(nickname)
            } else {
                awardText.append(teamKey.name)
            }
        } else if let awardee = awardee {
            awardText.append(awardee)
        } else {
            awardText.append("--")
        }
        return awardText
    }

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
    static func insert(_ model: TBAAwardRecipient, in context: NSManagedObjectContext) -> AwardRecipient {
        var predicate: NSPredicate {
            if let awardee = model.awardee, let teamKey = model.teamKey {
                return NSPredicate(format: "%K == %@ AND %K == %@",
                                   #keyPath(AwardRecipient.awardee), awardee,
                                   #keyPath(AwardRecipient.teamKey.key), teamKey)
            } else if let teamKey = model.teamKey {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(AwardRecipient.teamKey.key), teamKey)
            } else if let awardee = model.awardee {
                return NSPredicate(format: "%K == %@",
                                   #keyPath(AwardRecipient.awardee), awardee)
            } else {
                return NSPredicate(format: "%K == nil AND %K == nil",
                                   #keyPath(AwardRecipient.awardee),
                                   #keyPath(AwardRecipient.teamKey.key))
            }
        }

        return findOrCreate(in: context, matching: predicate) { (awardRecipient) in
            awardRecipient.updateToOneRelationship(relationship: #keyPath(AwardRecipient.teamKey), newValue: model.teamKey, newObject: {
                return TeamKey.insert(withKey: $0, in: context)
            })
            awardRecipient.awardee = model.awardee
        }
    }

    var isOrphaned: Bool {
        return awards?.count == 0
    }

}
