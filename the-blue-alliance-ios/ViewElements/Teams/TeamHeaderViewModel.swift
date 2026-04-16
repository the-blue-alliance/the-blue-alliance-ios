import Foundation
import UIKit

struct TeamHeaderViewModel {

    let teamNumber: Int
    let avatar: UIImage?
    let nickname: String?
    let teamNumberNickname: String
    let year: Int?

    init(teamNumber: Int, avatar: UIImage?, nickname: String?, teamNumberNickname: String, year: Int?) {
        self.teamNumber = teamNumber
        self.avatar = avatar
        self.nickname = nickname
        self.teamNumberNickname = teamNumberNickname
        self.year = year
    }

}
