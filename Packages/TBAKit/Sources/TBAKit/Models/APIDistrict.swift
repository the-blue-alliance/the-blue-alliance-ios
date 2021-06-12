//
//  APIDistrict.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct APIDistrict: Decodable {
    public let abbreviation: String
    public let name: String
    public let key: String
    public let year: Int

    enum CodingKeys: String, CodingKey {
        case abbreviation
        case name = "display_name"
        case key
        case year
    }
}

public struct APIDistrictRanking: Decodable {
    public let teamKey: String
    public let rank: Int
    public let rookieBonus: Int?
    public let pointTotal: Int
    public let eventPoints: [APIEventDistrictPointsPoints]

    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case rank
        case rookieBonus = "rookie_bonus"
        case pointTotal = "point_total"
        case eventPoints = "event_points"
    }
}
