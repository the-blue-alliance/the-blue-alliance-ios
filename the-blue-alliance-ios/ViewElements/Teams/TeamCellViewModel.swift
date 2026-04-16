import Foundation

struct TeamCellViewModel {

    let teamNumber: String
    let nickname: String
    let location: String?

    init(teamNumber: String, nickname: String, location: String?) {
        self.teamNumber = teamNumber
        self.nickname = nickname
        self.location = location
    }

}
