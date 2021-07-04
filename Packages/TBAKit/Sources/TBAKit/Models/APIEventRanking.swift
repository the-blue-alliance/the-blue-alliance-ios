//
//  APIEventRanking.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIEventRanking: Decodable {
    // TODO: This should be non-null - needs a fix upstream
    public var rankings: [APIEventRankingRanking]?
    public var extraStatsInfo: [APIEventRankingStat]?
    public var sortOrderInfo: [APIEventRankingStat]

    enum CodingKeys: String, CodingKey {
        case rankings
        case extraStatsInfo = "extra_stats_info"
        case sortOrderInfo = "sort_order_info"
    }
}

public struct APIEventRankingRanking: Decodable {
    public var teamKey: String
    public var rank: Int
    public var dq: Int?
    public var matchesPlayed: Int?
    public var qualAverage: Double?
    public var record: APIWLT?
    public var extraStats: [Double]?
    public var sortOrders: [Double]?

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
    public var name: String
    public var precision: Int
}
