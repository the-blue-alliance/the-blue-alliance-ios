import Foundation
import UIKit

struct TeamHeaderViewModel {

    let teamNumber: String

    let nickname: String?
    let hasNickname: Bool

    let avatar: UIImage?
    let hasAvatar: Bool

    let year: String

    init(team: Team, year: Int?) {
        self.teamNumber = team.fallbackNickname

        if let nickname = team.nickname {
            self.nickname = nickname
            self.hasNickname = true
        } else {
            self.nickname = nil
            self.hasNickname = false
        }

        if let year = year {
            self.year = "\(year)"
            // TODO: We *have* to not do this bullshit on the main thread
            if let avatar = team.avatar(year: year),
                let base64Image = avatar.details?["base64Image"] as? String,
                let avatarData = Data(base64Encoded: base64Image),
                let avatarImage = UIImage(data: avatarData) {
                self.avatar = avatarImage
                self.hasAvatar = true
            } else {
                self.avatar = nil
                self.hasAvatar = false
            }
        } else {
            self.year = "----"
            self.avatar = nil
            self.hasAvatar = false
        }
    }

}
