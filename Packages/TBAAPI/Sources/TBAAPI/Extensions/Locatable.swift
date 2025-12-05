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

public extension Locatable {
    var locationString: String? {
        let location = [city, stateProv, country].reduce("") { locationString, locationPart -> String in
            guard let locationPart, !locationPart.isEmpty else {
                return locationString
            }
            return locationString.isEmpty ? locationPart : "\(locationString), \(locationPart)"
        }
        return !location.isEmpty ? location : nil
    }
}
