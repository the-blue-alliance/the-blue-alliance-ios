//
//  APIEventTeamStatus.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIEventTeamStatus: Decodable {
    public var qual: APIEventTeamStatusQual?
    public var alliance: APIEventTeamStatusAlliance?
    public var playoff: APIAllianceStatus?

    public var allianceStatusString: String?
    public var playoffStatusString: String?
    public var overallStatusString: String?

    public var nextMatchKey: String?
    public var lastMatchKey: String?

    enum CodingKeys: String, CodingKey {
        case qual
        case alliance
        case playoff
        case allianceStatusString = "alliance_status_str"
        case playoffStatusString = "playoff_status_str"
        case overallStatusString = "overall_status_str"
        case nextMatchKey = "next_match_key"
        case lastMatchKey = "last_match_key"
    }
}

public struct APIEventTeamStatusQual: Decodable {
    public var numTeams: Int?
    public var status: String?
    public var ranking: APIEventRankingRanking?
    public var sortOrderInfo: [APIEventRankingStat]?

    enum CodingKeys: String, CodingKey {
        case numTeams = "num_teams"
        case status
        case ranking
        case sortOrderInfo = "sort_order_info"
    }
}

public struct APIEventTeamStatusAlliance: Decodable {
    public var number: Int
    public var pick: Int
    public var name: String?
    public var backup: APIAllianceBackup?

    enum CodingKeys: String, CodingKey {
        case number
        case pick
        case name
        case backup
    }
}
