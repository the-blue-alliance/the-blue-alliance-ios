//
//  Locatable.swift
//  TBAAPI
//
//  Created by Zachary Orr on 4/25/25.
//

public protocol Locatable {
    var city: String? { get }
    var stateProv: String? { get }
    var country: String? { get }
}

extension Locatable {

    public var locationString: String? {
        let location = [city, stateProv, country].reduce("", { (locationString, locationPart) -> String in
            guard let locationPart = locationPart, !locationPart.isEmpty else {
                return locationString
            }
            return locationString.isEmpty ? locationPart : "\(locationString), \(locationPart)"
        })
        return !location.isEmpty ? location : nil
    }

}
