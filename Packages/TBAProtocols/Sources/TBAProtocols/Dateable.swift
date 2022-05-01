import Foundation

public protocol Dateable {
    var startDate: Date? { get }
    var endDate: Date? { get }
}

extension Dateable {

    public var dateString: String? {
        guard let startDate = startDate, let endDate = endDate else {
            return nil
        }

        let calendar = Calendar.current

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MMM dd"

        let longDateFormatter = DateFormatter()
        longDateFormatter.dateFormat = "MMM dd, y"

        if startDate == endDate {
            return shortDateFormatter.string(from: endDate)
        } else if calendar.component(.year, from: startDate) == calendar.component(.year, from: endDate) {
            return "\(shortDateFormatter.string(from: startDate)) to \(shortDateFormatter.string(from: endDate))"
        }
        return "\(shortDateFormatter.string(from: startDate)) to \(longDateFormatter.string(from: endDate))"
    }

}
