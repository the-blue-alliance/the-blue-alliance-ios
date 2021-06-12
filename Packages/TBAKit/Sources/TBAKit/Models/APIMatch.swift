//
//  APIMatch.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIMatch: Decodable {
    public let key: String
    public let compLevel: String
    public let setNumber: Int
    public let matchNumber: Int
    public let alliances: [String: APIMatchAlliance]?
    public let winningAlliance: String?
    public let eventKey: String
    public let time: Int64?
    public let actualTime: Int64?
    public let predictedTime: Int64?
    public let postResultTime: Int64?
    public let breakdown: [String: Any]?
    public let videos: [APIMatchVideo]?

    enum CodingKeys: String, CodingKey {
        case key
        case compLevel = "comp_level"
        case setNumber = "set_number"
        case matchNumber = "match_number"
        case alliances
        case winningAlliance = "winning_alliance"
        case eventKey = "event_key"
        case time
        case actualTime = "actual_time"
        case predictedTime = "predicted_time"
        case postResultTime = "post_result_time"
        case breakdown = "score_breakdown"
        case videos
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(String.self, forKey: .key)
        compLevel = try values.decode(String.self, forKey: .compLevel)
        setNumber = try values.decode(Int.self, forKey: .setNumber)
        matchNumber = try values.decode(Int.self, forKey: .matchNumber)
        alliances = try values.decodeIfPresent([String: APIMatchAlliance].self, forKey: .alliances)
        winningAlliance = try values.decodeIfPresent(String.self, forKey: .winningAlliance)
        eventKey = try values.decode(String.self, forKey: .eventKey)
        time = try values.decodeIfPresent(Int64.self, forKey: .time)
        actualTime = try values.decodeIfPresent(Int64.self, forKey: .actualTime)
        predictedTime = try values.decodeIfPresent(Int64.self, forKey: .predictedTime)
        postResultTime = try values.decodeIfPresent(Int64.self, forKey: .postResultTime)
        breakdown = try values.decodeIfPresent([String: Any].self, forKey: .breakdown)
        videos = try values.decodeIfPresent([APIMatchVideo].self, forKey: .videos)
    }
}

public struct APIMatchVideo: Decodable {
    public let key: String
    public let type: String

    enum CodingKeys: String, CodingKey {
        case key
        case type
    }
}

public struct APIMatchAlliance: Decodable {
    public let score: Int
    public let teamKeys: [String]
    public let surrogateTeamKeys: [String]?
    public let dqTeamKeys: [String]?

    enum CodingKeys: String, CodingKey {
        case score
        case teamKeys = "team_keys"
        case surrogateTeamKeys = "surrogate_team_keys"
        case dqTeamKeys = "dq_team_keys"
    }
}

public struct APIMatchZebra: Decodable {
    public let key: String
    public let times: [Double]
    public let alliances: [String: [APIMachZebraTeam]]

    enum CodingKeys: String, CodingKey {
        case key
        case times
        case alliances
    }
}

public struct APIMachZebraTeam: Decodable {
    public let teamKey: String
    public let xs: [Double?]
    public let ys: [Double?]

    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case xs
        case ys
    }
}
