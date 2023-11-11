import Foundation
import TBAData
import UIKit

struct TeamHeaderViewModel {

    let teamNumber: Int
    let avatar: UIImage?
    let nickname: String?
    let teamNumberNickname: String
    let year: Int?

    init(team: Team, year: Int?) {
        teamNumber = team.teamNumber
        nickname = team.nickname
        teamNumberNickname = team.teamNumberNickname
        self.year = year ?? nil

        // TODO: We *have* to not do this bullshit on the main thread
        if let year = year,
            let avatar = team.avatar(year: year),
            let base64Image = avatar.details?["base64Image"] as? String,
            let avatarData = Data(base64Encoded: base64Image),
            let avatarImage = UIImage(data: avatarData) {
            self.avatar = avatarImage
        } else {
            avatar = nil
        }
    }

}
