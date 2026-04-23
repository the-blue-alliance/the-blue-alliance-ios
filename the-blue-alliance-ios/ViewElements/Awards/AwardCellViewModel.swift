import Foundation
import TBAAPI

struct Recipient {
    let teamKey: String?
    let awardText: [String]
}

struct AwardCellViewModel {

    let awardName: String?
    let recipients: [Recipient]

    init(award: Award, teamsByKey: [String: TeamSimple] = [:]) {
        awardName = award.name
        recipients = award.recipientList.map { apiRecipient in
            var awardText: [String] = []
            if let teamKey = apiRecipient.teamKey, let awardee = apiRecipient.awardee {
                awardText.append(awardee)
                awardText.append(Self.teamDisplay(key: teamKey, teamsByKey: teamsByKey))
            } else if let teamKey = apiRecipient.teamKey {
                awardText.append(Self.teamDisplay(key: teamKey, teamsByKey: teamsByKey))
            } else if let awardee = apiRecipient.awardee {
                awardText.append(awardee)
            } else {
                awardText.append("--")
            }
            return Recipient(teamKey: apiRecipient.teamKey, awardText: awardText)
        }
    }

    private static func teamDisplay(key: String, teamsByKey: [String: TeamSimple]) -> String {
        if let team = teamsByKey[key] {
            return team.displayNickname
        }
        if key.hasPrefix("frc") {
            return "Team \(key.dropFirst(3))"
        }
        return key
    }
}
