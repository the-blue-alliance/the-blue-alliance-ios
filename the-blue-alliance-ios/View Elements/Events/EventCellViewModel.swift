import Foundation

struct EventCellViewModel {

    let eventShortname: String
    let eventWeek: String?
    let eventLocation: String?
    let eventDate: String?

    init(event: Event) {
        eventShortname = event.safeShortName
        eventLocation = event.locationString
        eventDate = event.dateString()
        
        /**
         Only show the week number if the event if it is in Week 1..7
         Other events (Offseason, Championships, Preseason) already have their descriptions in the table view.
         */
        if event.weekString.contains("Week") {
            eventWeek = event.weekString
        }
        else {
            eventWeek = nil
        }
    }

}
