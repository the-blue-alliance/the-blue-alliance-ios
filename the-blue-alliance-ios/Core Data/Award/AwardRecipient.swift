import Foundation
import CoreData
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
        }
        return awardText
    }

}

extension AwardRecipient: Managed {

    /**
     As a note - these can't really be updated - they can be deleted from Award, but predicates for this
     generally won't match new models for updates.
     */
    static func insert(_ model: TBAAwardRecipient, award: Award, in context: NSManagedObjectContext) -> AwardRecipient {
        var predicate: NSPredicate {
            if let awardee = model.awardee, let teamKey = model.teamKey {
                return NSPredicate(format: "%K == %@ AND %K == %@ AND %K == %@",
                                   #keyPath(AwardRecipient.awardee), awardee,
                                   #keyPath(AwardRecipient.teamKey.key), teamKey,
                                   #keyPath(AwardRecipient.award), award)
            } else if let teamKey = model.teamKey {
                return NSPredicate(format: "%K == %@ AND %K == %@",
                                   #keyPath(AwardRecipient.teamKey.key), teamKey,
                                   #keyPath(AwardRecipient.award), award)
            } else if let awardee = model.awardee {
                return NSPredicate(format: "%K == %@ AND %K == %@",
                                   #keyPath(AwardRecipient.awardee), awardee,
                                   #keyPath(AwardRecipient.award), award)
            } else {
                fatalError("Award has no info")
            }
        }

        return findOrCreate(in: context, matching: predicate) { (awardRecipient) in
            updateToOneRelationship(relationship: &awardRecipient.teamKey, newValue: model.teamKey) {
                return TeamKey.insert(withKey: $0, in: context)
            }
            awardRecipient.awardee = model.awardee
            awardRecipient.award = award
        }
    }

}
