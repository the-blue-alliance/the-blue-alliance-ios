//
//  APITeam.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct APITeam: Decodable {
    public let key: String
    public let teamNumber: Int
    public let nickname: String?
    public let name: String?
    public let schoolName: String?
    public let city: String?
    public let stateProv: String?
    public let country: String?
    public let address: String?
    public let postalCode: String?
    public let gmapsPlaceID: String?
    public let gmapsURL: String?
    public let lat: Double?
    public let lng: Double?
    public let locationName: String?
    public let website: String?
    public let rookieYear: Int?
    public let homeChampionship: [String: String]?

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
