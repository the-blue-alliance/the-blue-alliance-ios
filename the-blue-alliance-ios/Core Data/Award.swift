import Foundation
import CoreData
import TBAKit

extension Award: Managed {

    static func insert(with model: TBAAward, for event: Event, in context: NSManagedObjectContext) -> Award {
        let predicate = NSPredicate(format: "awardType == %ld && year == %ld && event == %@", model.awardType, model.year, event)
        return findOrCreate(in: context, matching: predicate) { (award) in
            // Required: awardType, event, name, year, recipients
            award.name = model.name
            award.awardType = Int16(model.awardType)
            award.event = event
            award.year = Int16(model.year)

            award.recipients = Set(model.recipients.map({ (modelRecipient) -> AwardRecipient in
                return AwardRecipient.insert(with: modelRecipient, for: award, in: context)
            })) as NSSet
        }
    }

}

extension AwardRecipient: Managed {

    static func insert(with model: TBAAwardRecipient, for award: Award, in context: NSManagedObjectContext) -> AwardRecipient {
        var predicate: NSPredicate?
        var team: TeamKey?
        if let awardee = model.awardee, let teamKey = model.teamKey {
            team = TeamKey.insert(withKey: teamKey, in: context)
            predicate = NSPredicate(format: "awardee == %@ AND award == %@ AND teamKey == %@", awardee, award, team!)
        } else if let teamKey = model.teamKey {
            team = TeamKey.insert(withKey: teamKey, in: context)
            predicate = NSPredicate(format: "teamKey == %@ AND award == %@", team!, award)
        } else if let awardee = model.awardee {
            predicate = NSPredicate(format: "awardee == %@ AND award == %@", awardee, award)
        } else {
            fatalError("Award has no info")
        }

        return findOrCreate(in: context, matching: predicate!) { (awardRecipient) in
            awardRecipient.teamKey = team
            awardRecipient.awardee = model.awardee
            awardRecipient.award = award
        }
    }

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
