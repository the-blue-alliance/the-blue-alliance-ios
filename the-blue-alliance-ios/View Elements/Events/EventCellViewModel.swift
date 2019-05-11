import Foundation

struct EventCellViewModel {

    let eventShortname: String
    let eventWeek: String?
    let eventLocation: String?
    let eventDate: String?

    init(event: Event, eventWeekVisible: Bool) {
        eventShortname = event.safeShortName
        eventWeek = eventWeekVisible ? event.weekString : nil
        eventLocation = event.locationString
        eventDate = event.dateString()
    }

}
