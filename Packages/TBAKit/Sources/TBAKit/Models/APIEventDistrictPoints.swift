//
//  APIEventDistrictPoints.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIEventDistrictPoints: Decodable {
    public var points: [String: APIEventDistrictPointsPoints]
    public var tiebreakers: [String: APIEventDistrictPointsTiebreaker]
}

public struct APIEventDistrictPointsPoints: Decodable {
    public var eventKey: String?
    public var districtCMP: Bool?
    public var alliancePoints: Int
    public var awardPoints: Int
    public var qualPoints: Int
    public var elimPoints: Int
    public var total: Int

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
    public var highestQualScores: [Int]
    public var qualWins: Int

    enum CodingKeys: String, CodingKey {
        case highestQualScores = "highest_qual_scores"
        case qualWins = "qual_wins"
    }
}
