import Foundation
import TBAData

struct EventCellViewModel {

    let eventShortname: String
    let eventLocation: String?
    let eventDate: String?

    init(event: Event) {
        eventShortname = event.safeShortName
        eventLocation = event.locationString
        eventDate = event.dateString()
    }

}
