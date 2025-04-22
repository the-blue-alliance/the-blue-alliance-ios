//
//  APITeam.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct Team: Decodable, Sendable {
    public var key: String
    public var teamNumber: Int
    public var nickname: String?
    public var name: String?
    public var schoolName: String?
    public var city: String?
    public var stateProv: String?
    public var country: String?
    public var address: String?
    public var postalCode: String?
    public var gmapsPlaceID: String?
    public var gmapsURL: String?
    public var lat: Double?
    public var lng: Double?
    public var locationName: String?
    public var website: String?
    public var rookieYear: Int?
    public var homeChampionship: [String: String]?

    enum CodingKeys: String, CodingKey {
        case key
        case teamNumber = "team_number"
        case nickname
        case name
        case schoolName = "school_name"
        case city
        case stateProv = "state_prov"
        case country
        case address
        case postalCode = "postal_code"
        case gmapsPlaceID = "gmaps_place_id"
        case gmapsURL = "gmaps_url"
        case lat
        case lng
        case locationName = "location_name"
        case website
        case rookieYear = "rookie_year"
        case homeChampionship = "home_championship"
    }
}

extension Team: Hashable {}

extension Team {
    /**
     The team number name for the team
     Ex: "Team 7332"
     */
    public var teamNumberNickname: String {
        return "Team \(teamNumber)"
    }

    public var displayName: String {
        return nickname ?? teamNumberNickname
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
