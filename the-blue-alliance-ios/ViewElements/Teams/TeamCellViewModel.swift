import Foundation
import TBAData
import TBAModels

struct TeamCellViewModel {

    let teamNumber: String
    let nickname: String
    let location: String?

    init(team: TBAData.Team) {
        teamNumber = "\(team.teamNumber)"
        nickname = team.nickname ?? team.teamNumberNickname
        location = team.locationString
    }

    init(team: TBAModels.Team) {
        teamNumber = "\(team.teamNumber)"
        nickname = team.nickname ?? team.teamNumberNickname
        location = team.locationName
    }

    init(teamNumber: String, nickname: String, location: String?) {
        self.teamNumber = teamNumber
        self.nickname = nickname
        self.location = location
    }
}
