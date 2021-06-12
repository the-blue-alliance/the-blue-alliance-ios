//
//  APIEventDistrictPoints.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIEventDistrictPoints: Decodable {
    public let points: [String: APIEventDistrictPointsPoints]
    public let tiebreakers: [String: APIEventDistrictPointsTiebreaker]
}

public struct APIEventDistrictPointsPoints: Decodable {
    public let eventKey: String?
    public let districtCMP: Bool?
    public let alliancePoints: Int
    public let awardPoints: Int
    public let qualPoints: Int
    public let elimPoints: Int
    public let total: Int

    enum CodingKeys: String, CodingKey {
        case eventKey = "event_key"
        case districtCMP = "district_cmp"
        case alliancePoints = "alliance_points"
        case awardPoints = "award_points"
        case qualPoints = "qual_points"
        case elimPoints = "elim_points"
        case total
    }
}

public struct APIEventDistrictPointsTiebreaker: Decodable {
    public let highestQualScores: [Int]
    public let qualWins: Int

    enum CodingKeys: String, CodingKey {
        case highestQualScores = "highest_qual_scores"
        case qualWins = "qual_wins"
    }
}
