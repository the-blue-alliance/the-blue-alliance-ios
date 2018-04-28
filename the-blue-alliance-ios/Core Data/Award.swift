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
        var team: Team?
        if let awardee = model.awardee, let teamKey = model.teamKey {
            team = Team.insert(withKey: teamKey, in: context)
            predicate = NSPredicate(format: "awardee == %@ AND award == %@ AND team == %@", awardee, award, team!)
        } else if let teamKey = model.teamKey {
            team = Team.insert(withKey: teamKey, in: context)
            predicate = NSPredicate(format: "team == %@ AND award == %@", team!, award)
        } else if let awardee = model.awardee {
            predicate = NSPredicate(format: "awardee == %@ AND award == %@", awardee, award)
        } else {
            fatalError("Award has no info")
        }

        return findOrCreate(in: context, matching: predicate!) { (awardRecipient) in
            awardRecipient.team = team
            awardRecipient.awardee = model.awardee
            awardRecipient.award = award
        }
    }
    
    public var awardText: [String] {
        var awardText: [String] = []
        if let team = team, let awardee = awardee {
            awardText.append(awardee)
            awardText.append(team.nickname ?? team.fallbackNickname)
        } else if let team = team {
            if team.nickname != nil {
                awardText.append("\(team.teamNumber)")
            }
            awardText.append(team.nickname ?? team.fallbackNickname)
        } else if let awardee = awardee {
            awardText.append(awardee)
        }
        return awardText
    }
    
}
