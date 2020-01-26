import CoreSpotlight
import Foundation
import TBAProtocols

extension CSSearchableItem: Locatable {

    public var city: String? {
        return attributeSet.city
    }

    public var stateProv: String? {
        return attributeSet.stateOrProvince
    }

    public var country: String? {
        return attributeSet.country
    }

    public var locationName: String? {
        return attributeSet.namedLocation
    }

}

extension CSSearchableItemAttributeSet: Locatable {

    public var stateProv: String? {
        return stateOrProvince
    }

    public var locationName: String? {
        return namedLocation
    }

}
