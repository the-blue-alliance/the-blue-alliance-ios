import Foundation

struct Recipient {
    let teamKey: String?
    let awardText: [String]
    let teamNumber: String?
    let teamName: String?
    let awardee: String?
}

struct AwardCellViewModel {

    let awardName: String?
    // array of award texts for recipients
    let recipients: [Recipient]

    init(award: Award) {
        awardName = award.name
        recipients = (award.recipients?.allObjects as? [AwardRecipient])?.map({ (recipient) -> Recipient in
            let name = recipient.teamKey?.team?.nickname ?? recipient.teamKey?.team?.name
            return Recipient(teamKey: recipient.teamKey?.key, awardText: recipient.awardText, teamNumber: recipient.teamKey?.teamNumber, teamName: name, awardee: recipient.awardee)
        }) ?? []
    }

}
