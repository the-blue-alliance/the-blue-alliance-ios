//
//  DistrictRanking.swift
//  TBAModels
//
//  Created by Zachary Orr on 4/20/25.
//

public struct DistrictRanking: Decodable {
    public var teamKey: String
    public var rank: Int
    public var rookieBonus: Int?
    public var pointTotal: Int
    public var eventPoints: [EventDistrictPointsPoints]

    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case rank
        case rookieBonus = "rookie_bonus"
        case pointTotal = "point_total"
        case eventPoints = "event_points"
    }
}

extension DistrictRanking: Equatable, Hashable, Sendable {}
