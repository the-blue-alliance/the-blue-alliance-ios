import CoreSpotlight
import Foundation
import TBAProtocols

extension CSSearchableItem: Dateable {

    public var startDate: Date? {
        return attributeSet.startDate
    }

    public var endDate: Date? {
        return attributeSet.endDate
    }

}
