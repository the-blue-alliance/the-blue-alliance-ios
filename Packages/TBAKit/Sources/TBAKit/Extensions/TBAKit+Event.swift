//
//  TBAKit+Event.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

extension TBAKit {

    public func eventsAll() async throws -> [APIEvent] {
        let endpoint = "events/all"
        return try await fetch(endpoint)
    }

    public func events(year: Int) async throws -> [APIEvent] {
        let endpoint = "events/\(year)"
        return try await fetch(endpoint)
    }

    public func event(key: String) async throws -> APIEvent {
        let endpoint = "event/\(key)"
        return try await fetch(endpoint)
    }

    public func eventAlliances(key: String) async throws -> [APIAlliance] {
        let endpoint = "event/\(key)/alliances"
        return try await fetch(endpoint)
    }

    public func eventAwards(key: String) async throws -> [APIAward] {
        let endpoint = "event/\(key)/awards"
        return try await fetch(endpoint)
    }

    public func eventDistrictPoints(key: String) async throws -> APIEventDistrictPoints {
        let endpoint = "event/\(key)/district_points"
        return try await fetch(endpoint)
    }

    public func eventRankings(key: String) async throws -> APIEventRanking {
        let endpoint = "event/\(key)/rankings"
        return try await fetch(endpoint)
    }

    public func eventMatches(key: String) async throws -> [APIMatch] {
        let endpoint = "event/\(key)/matches"
        return try await fetch(endpoint)
    }

    public func eventTeams(key: String) async throws -> [APITeam] {
        let endpoint = "event/\(key)/teams"
        return try await fetch(endpoint)
    }

    public func eventInsights(key: String) async throws -> APIEventInsights {
        let endpoint = "event/\(key)/insights"
        return try await fetch(endpoint)
    }

    public func eventStats(key: String) async throws -> APIEventStats {
        let endpoint = "event/\(key)/oprs"
        return try await fetch(endpoint)
    }

    public func eventTeamStatuses(key: String) async throws -> [String: APIEventTeamStatus] {
        let endpoint = "event/\(key)/teams/statuses"
        return try await fetch(endpoint)
    }

}
