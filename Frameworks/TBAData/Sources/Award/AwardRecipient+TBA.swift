import CoreData
import Foundation
import TBAKit

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

extension AwardRecipient: Managed {

    public var isOrphaned: Bool {
        return awards.count == 0
    }

}
