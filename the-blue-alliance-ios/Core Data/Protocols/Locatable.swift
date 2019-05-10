import Foundation

// Does the model have enough information to be found by a travel agent.
protocol Locatable {
    var city: String? { get }
    var stateProv: String? { get }
    var country: String? { get }
    var locationName: String? { get }
}

extension Locatable {

    var locationString: String? {
        let location = [city, stateProv, country].reduce("", { (locationString, locationPart) -> String in
            guard let locationPart = locationPart, !locationPart.isEmpty else {
                return locationString
            }
            return locationString.isEmpty ? locationPart : "\(locationString), \(locationPart)"
        })
        return !location.isEmpty ? location : locationName
    }

}
