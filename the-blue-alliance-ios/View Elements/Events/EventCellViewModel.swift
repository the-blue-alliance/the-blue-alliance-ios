import Foundation

struct EventCellViewModel {

    let eventShortname: String
    let eventWeek: String?
    let eventLocation: String?
    let eventDate: String?

    init(event: Event) {
        eventShortname = event.safeShortName
        eventWeek = event.weekString
        eventLocation = event.locationString
        eventDate = event.dateString()
    }

}
