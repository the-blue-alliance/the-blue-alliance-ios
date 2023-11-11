import Foundation
import TBAData

struct TeamCellViewModel {

    let teamNumber: String
    let nickname: String
    let location: String?

    init(team: Team) {
        teamNumber = "\(team.teamNumber)"
        nickname = team.nickname ?? team.teamNumberNickname
        location = team.locationString
    }

    init(teamNumber: String, nickname: String, location: String?) {
        self.teamNumber = teamNumber
        self.nickname = nickname
        self.location = location
    }

}
