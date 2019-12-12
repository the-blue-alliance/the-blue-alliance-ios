import Foundation
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
        recipients = (award.recipients.allObjects as? [AwardRecipient])?.map {
            return Recipient(teamKey: $0.team?.key, awardText: $0.awardText)
        } ?? []
    }
}
