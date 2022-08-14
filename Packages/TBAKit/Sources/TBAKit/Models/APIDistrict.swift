//
//  APIDistrict.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct APIDistrict: Decodable {
    public var abbreviation: String
    public var name: String
    public var key: String
    public var year: Int

    enum CodingKeys: String, CodingKey {
        case abbreviation
        case name = "display_name"
        case key
        case year
    }
}

public struct APIDistrictRanking: Decodable {
    public var teamKey: String
    public var rank: Int
    public var rookieBonus: Int?
    public var pointTotal: Int
    public var eventPoints: [APIEventDistrictPointsPoints]

    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case rank
        case rookieBonus = "rookie_bonus"
        case pointTotal = "point_total"
        case eventPoints = "event_points"
    }
}
