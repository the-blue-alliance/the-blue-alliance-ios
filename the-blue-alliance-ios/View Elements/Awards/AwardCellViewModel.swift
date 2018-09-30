import Foundation

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
        recipients = (award.recipients?.allObjects as? [AwardRecipient])?.map({ (recipient) -> Recipient in
            return Recipient(teamKey: recipient.team?.key, awardText: recipient.awardText)
        }) ?? []
    }
}
