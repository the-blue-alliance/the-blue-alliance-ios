import Foundation

struct InfoCellViewModel {

    let nameString: String
    let subtitleStrings: [String]

    init(event: Event) {
        nameString = event.name!
        subtitleStrings = [event.locationString, event.dateString()].compactMap({ $0 })
    }

    init(team: Team) {
        nameString = team.nickname ?? team.fallbackNickname
        subtitleStrings = [team.locationString, team.motto].compactMap({ $0 })
    }

}
