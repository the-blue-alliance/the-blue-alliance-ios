import Foundation

// Does the model have enough information to be found by a travel agent.
public protocol Locatable {
    var city: String? { get }
    var stateProv: String? { get }
    var country: String? { get }
    var locationName: String? { get }
}

extension Locatable {

    public var hasLocation: Bool {
        if let locationString = locationString, !locationString.isEmpty {
            return true
        }
        return false
    }

    public var locationString: String? {
        let location = [city, stateProv, country].reduce("", { (locationString, locationPart) -> String in
            guard let locationPart = locationPart, !locationPart.isEmpty else {
                return locationString
            }
            return locationString.isEmpty ? locationPart : "\(locationString), \(locationPart)"
        })
        return !location.isEmpty ? location : locationName
    }

}
