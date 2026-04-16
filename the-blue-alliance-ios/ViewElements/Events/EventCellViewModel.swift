import Foundation

struct EventCellViewModel {

    let name: String
    let location: String?
    let dateString: String?

    init(name: String, location: String?, dateString: String?) {
        self.name = name
        self.location = location
        self.dateString = dateString
    }

}
