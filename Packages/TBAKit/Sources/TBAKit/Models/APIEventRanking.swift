//
//  APIEventRanking.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIEventRanking: Decodable {
    // TODO: This should be non-null - needs a fix upstream
    public let rankings: [APIEventRankingRanking]?
    public let extraStatsInfo: [APIEventRankingStat]?
    public let sortOrderInfo: [APIEventRankingStat]

    enum CodingKeys: String, CodingKey {
        case rankings
        case extraStatsInfo = "extra_stats_info"
        case sortOrderInfo = "sort_order_info"
    }
}

public struct APIEventRankingRanking: Decodable {
    public let teamKey: String
    public let rank: Int
    public let dq: Int?
    public let matchesPlayed: Int?
    public let qualAverage: Double?
    public let record: APIWLT?
    public let extraStats: [Double]?
    public let sortOrders: [Double]?

    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case rank
        case dq
        case matchesPlayed = "matches_played"
        case qualAverage = "qual_average"
        case record
        case extraStats = "extra_stats"
        case sortOrders = "sort_orders"
    }
}

public struct APIEventRankingStat: Decodable {
    public let name: String
    public let precision: Int
}
