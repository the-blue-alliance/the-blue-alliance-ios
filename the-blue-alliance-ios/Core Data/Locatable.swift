//
//  Locatable.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/13/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation

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
