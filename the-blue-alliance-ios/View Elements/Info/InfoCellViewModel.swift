import Foundation
import TBAData

struct InfoCellViewModel {

    let nameString: String
    let subtitleStrings: [String]

    init(event: Event) {
        nameString = event.name ?? event.key
        subtitleStrings = [event.locationString, event.dateString()].compactMap({ $0 })
    }

    init(team: Team) {
        nameString = team.nickname ?? team.teamNumberNickname
        subtitleStrings = [team.locationString].compactMap({ $0 })
    }

}
