import Foundation
import TBAAPI

struct InfoCellViewModel {

    let nameString: String
    let subtitleStrings: [String]

    init(event: Components.Schemas.Event) {
        nameString = event.name.isEmpty ? event.key : event.name
        subtitleStrings = [event.locationString, event.dateString, event.weekString].compactMap { $0 }
    }

    init(nameString: String, subtitleStrings: [String]) {
        self.nameString = nameString
        self.subtitleStrings = subtitleStrings
    }

}
