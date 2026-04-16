import Foundation
import TBAAPI
import TBAData
import TBAProtocols

struct InfoCellViewModel {

    let nameString: String
    let subtitleStrings: [String]

    init(event: Event) {
        nameString = event.name ?? event.key
        subtitleStrings = [event.locationString, event.dateString, event.weekString].compactMap({ $0 })
    }

    init(event: Components.Schemas.Event) {
        nameString = event.name.isEmpty ? event.key : event.name
        subtitleStrings = [event.locationString, event.dateString, event.weekString].compactMap { $0 }
    }

    init(team: Team) {
        nameString = team.nickname ?? team.teamNumberNickname
        subtitleStrings = [team.locationString].compactMap({ $0 })
    }

    init(nameString: String, subtitleStrings: [String]) {
        self.nameString = nameString
        self.subtitleStrings = subtitleStrings
    }

}
