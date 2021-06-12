//
//  APIEvent.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct APIEvent: Decodable {
    public let key: String
    public let name: String
    public let eventCode: String
    public let eventType: Int
    public let district: APIDistrict?
    public let city: String?
    public let stateProv: String?
    public let country: String?
    public let startDate: Date
    public let endDate: Date
    public let year: Int
    public let shortName: String?
    public let eventTypeString: String
    public let week: Int?
    public let address: String?
    public let postalCode: String?
    public let gmapsPlaceID: String?
    public let gmapsURL: String?
    public let lat: Double?
    public let lng: Double?
    public let locationName: String?
    public let timezone: String?
    public let website: String?
    public let firstEventID: String?
    public let firstEventCode: String?
    public let webcasts: [APIWebcast]?
    public let divisionKeys: [String]
    public let parentEventKey: String?
    public let playoffType: Int?
    public let playoffTypeString: String?

    enum CodingKeys: String, CodingKey {
        case key
        case name
        case eventCode = "event_code"
        case eventType = "event_type"
        case district
        case city
        case stateProv = "state_prov"
        case country
        case startDate = "start_date"
        case endDate = "end_date"
        case year
        case shortName = "short_name"
        case eventTypeString = "event_type_string"
        case week
        case address
        case postalCode = "postal_code"
        case gmapsPlaceID = "gmaps_place_id"
        case gmapsURL = "gmaps_url"
        case lat
        case lng
        case locationName = "location_name"
        case timezone
        case website
        case firstEventID = "first_event_id"
        case firstEventCode = "first_event_code"
        case webcasts
        case divisionKeys = "division_keys"
        case parentEventKey = "parent_event_key"
        case playoffType = "playoff_type"
        case playoffTypeString = "playoff_type_string"
    }
}
