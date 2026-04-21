import Foundation

struct TeamCellViewModel {

    let teamNumber: String
    let nickname: String
    let location: String?
    let numberSubtitle: String?

    init(
        teamNumber: String,
        nickname: String,
        location: String?,
        numberSubtitle: String? = nil
    ) {
        self.teamNumber = teamNumber
        self.nickname = nickname
        self.location = location
        self.numberSubtitle = numberSubtitle
    }

}
