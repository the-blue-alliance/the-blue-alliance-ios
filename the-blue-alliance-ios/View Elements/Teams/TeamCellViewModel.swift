import Foundation
import TBAData

struct TeamCellViewModel {

    let teamNumber: String
    let teamNickname: String
    let teamLocation: String?

    init(team: Team) {
        teamNumber = "\(team.teamNumber!.stringValue)"
        teamNickname = team.nickname ?? team.fallbackNickname
        teamLocation = team.locationString
    }

}
