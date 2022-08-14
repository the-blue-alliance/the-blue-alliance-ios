//
//  APIEvent.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

// https://github.com/the-blue-alliance/the-blue-alliance/blob/py3/src/backend/common/consts/event_type.py
public enum APIEventType: Int {
    case regional = 0
    case district = 1
    case districtChampionship = 2
    case championshipDivision = 3
    case championshipFinals = 4
    case districtChampionshipDivision = 5
    case festivalOfChampions = 6
    case remote = 7
    case offseason = 99
    case preseason = 100
    case unlabeled = -1
}

public struct APIEvent: Decodable {
    public var key: String
    public var name: String
    public var eventCode: String
    public var eventType: Int
    public var district: APIDistrict?
    public var city: String?
    public var stateProv: String?
    public var country: String?
    public var startDate: Date
    public var endDate: Date
    public var year: Int
    public var shortName: String?
    public var eventTypeString: String
    public var week: Int?
    public var address: String?
    public var postalCode: String?
    public var gmapsPlaceID: String?
    public var gmapsURL: String?
    public var lat: Double?
    public var lng: Double?
    public var locationName: String?
    public var timezone: String?
    public var website: String?
    public var firstEventID: String?
    public var firstEventCode: String?
    public var webcasts: [APIWebcast]?
    public var divisionKeys: [String]
    public var parentEventKey: String?
    public var playoffType: Int?
    public var playoffTypeString: String?

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
