import Foundation
import TBAAPI
import TBAData

struct Recipient {
    let teamKey: String?
    let awardText: [String]
}

struct AwardCellViewModel {

    let awardName: String?
    // array of award texts for recipients
    let recipients: [Recipient]

    init(award: Award) {
        awardName = award.name
        recipients = award.recipients.map {
            return Recipient(teamKey: $0.team?.key, awardText: $0.awardText)
        }
    }

    init(award: Components.Schemas.Award) {
        awardName = award.name
        recipients = award.recipientList.map { apiRecipient in
            var awardText: [String] = []
            if let teamKey = apiRecipient.teamKey, let awardee = apiRecipient.awardee {
                awardText.append(awardee)
                awardText.append(Self.teamDisplay(key: teamKey))
            } else if let teamKey = apiRecipient.teamKey {
                awardText.append(Self.teamDisplay(key: teamKey))
            } else if let awardee = apiRecipient.awardee {
                awardText.append(awardee)
            } else {
                awardText.append("--")
            }
            return Recipient(teamKey: apiRecipient.teamKey, awardText: awardText)
        }
    }

    // Lightweight team display without fetching the full team. Phase 3 will
    // reintroduce nickname lookup once Teams are on TBAAPI too.
    private static func teamDisplay(key: String) -> String {
        if key.hasPrefix("frc") {
            return "Team \(key.dropFirst(3))"
        }
        return key
    }
}
