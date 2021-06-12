//
//  APIStatus.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct APIStatus: Decodable {
    public let android: APIAppInfo
    public let ios: APIAppInfo
    public let currentSeason: Int
    public let downEvents: [String]
    public let datafeedDown: Bool
    public let maxSeason: Int

    enum CodingKeys: String, CodingKey {
        case android
        case ios
        case currentSeason = "current_season"
        case downEvents = "down_events"
        case datafeedDown = "is_datafeed_down"
        case maxSeason = "max_season"
    }
}

public struct APIAppInfo: Decodable {
    public let latestAppVersion: Int
    public let minAppVersion: Int

    enum CodingKeys: String, CodingKey {
        case latestAppVersion = "latest_app_version"
        case minAppVersion = "min_app_version"
    }
}
