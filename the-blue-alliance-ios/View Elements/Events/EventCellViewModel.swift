import Foundation
import TBAData
import TBAProtocols

struct EventCellViewModel {

    let name: String
    let location: String?
    let dateString: String?

    init(event: Event) {
        name = event.safeShortName
        location = event.locationString
        dateString = event.dateString
    }

    init(name: String, location: String?, dateString: String?) {
        self.name = name
        self.location = location
        self.dateString = dateString
    }

}
