//
//  Status.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct Status: Codable {
    public var ios: AppInfo
    public var currentSeason: Int
    public var downEvents: [String]
    public var datafeedDown: Bool
    public var maxSeason: Int
    public var maxTeamPage: Int

    enum CodingKeys: String, CodingKey {
        case ios
        case currentSeason = "current_season"
        case downEvents = "down_events"
        case datafeedDown = "is_datafeed_down"
        case maxSeason = "max_season"
        case maxTeamPage = "max_team_page"
    }

    public init(ios: AppInfo, currentSeason: Int, downEvents: [String], datafeedDown: Bool, maxSeason: Int, maxTeamPage: Int) {
        self.ios = ios
        self.currentSeason = currentSeason
        self.downEvents = downEvents
        self.datafeedDown = datafeedDown
        self.maxSeason = maxSeason
        self.maxTeamPage = maxTeamPage
    }
}

extension Status: CustomStringConvertible {
    public var description: String {
        return "Status(ios=\(ios), currentSeason=\(currentSeason), downEvents=\(downEvents), datafeedDown=\(datafeedDown), maxSeason=\(maxSeason), maxTeamPage=\(maxTeamPage))"
    }
}

public struct AppInfo: Codable {
    public var latestAppVersion: Int
    public var minAppVersion: Int

    enum CodingKeys: String, CodingKey {
        case latestAppVersion = "latest_app_version"
        case minAppVersion = "min_app_version"
    }

    public init(latestAppVersion: Int, minAppVersion: Int) {
        self.latestAppVersion = latestAppVersion
        self.minAppVersion = minAppVersion
    }

    public init() {
        self.latestAppVersion = -1
        self.minAppVersion = -1
    }
}

extension AppInfo: CustomStringConvertible {
    public var description: String {
        return "AppInfo(latestAppVersion=\(latestAppVersion), minAppVersion=\(minAppVersion))"
    }
}
