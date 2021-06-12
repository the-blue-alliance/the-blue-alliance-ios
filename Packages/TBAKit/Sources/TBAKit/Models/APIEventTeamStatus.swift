//
//  APIEventTeamStatus.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIEventTeamStatus: Decodable {
    public let qual: APIEventTeamStatusQual?
    public let alliance: APIEventTeamStatusAlliance?
    public let playoff: APIAllianceStatus?

    public let allianceStatusString: String?
    public let playoffStatusString: String?
    public let overallStatusString: String?

    public let nextMatchKey: String?
    public let lastMatchKey: String?

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
    public let numTeams: Int?
    public let status: String?
    public let ranking: APIEventRankingRanking?
    public let sortOrderInfo: [APIEventRankingStat]?

    enum CodingKeys: String, CodingKey {
        case numTeams = "num_teams"
        case status
        case ranking
        case sortOrderInfo = "sort_order_info"
    }
}

public struct APIEventTeamStatusAlliance: Decodable {
    public let number: Int
    public let pick: Int
    public let name: String?
    public let backup: APIAllianceBackup?

    enum CodingKeys: String, CodingKey {
        case number
        case pick
        case name
        case backup
    }
}
