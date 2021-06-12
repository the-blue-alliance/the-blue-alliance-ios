//
//  TBAKit+Team.swift
//  
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

extension TBAKit {

    public func teams(simple: Bool = false) async throws -> [APITeam] {
        let endpoint = simple ? "teams/all/simple" : "teams/all"
        return try await fetch(endpoint)
    }

    public func teams(page: Int, year: Int? = nil) async throws -> [APITeam] {
        var endpoint = "teams"
        if let year = year {
            endpoint = "\(endpoint)/\(year)"
        }
        endpoint = "\(endpoint)/\(page)"
        return try await fetch(endpoint)
    }

    public func team(key: String) async throws -> APITeam {
        let endpoint = "team/\(key)"
        return try await fetch(endpoint)
    }

    public func teamYearsParticipated(key: String) async throws -> [Int] {
        let endpoint = "team/\(key)/years_participated"
        return try await fetch(endpoint)
    }

    public func teamDistricts(key: String) async throws -> [APIDistrict] {
        let endpoint = "team/\(key)/districts"
        return try await fetch(endpoint)
    }

    public func teamRobots(key: String) async throws -> [APIRobot] {
        let endpoint = "team/\(key)/robots"
        return try await fetch(endpoint)
    }

    public func teamEvents(key: String, year: Int? = nil) async throws -> [APIEvent] {
        var endpoint = "team/\(key)/events"
        if let year = year {
            endpoint = "\(endpoint)/\(year)"
        }
        return try await fetch(endpoint)
    }

    public func teamStatuses(key: String, year: Int) async throws -> [String: APIEventTeamStatus?] {
        let endpoint = "team/\(key)/events/\(year)/statuses"
        return try await fetch(endpoint)
    }

    public func teamStatus(key: String, eventKey: String) async throws -> APIEventTeamStatus {
        let endpoint = "team/\(key)/event/\(eventKey)/status"
        return try await fetch(endpoint)
    }

    public func teamMatches(key: String, year: Int) async throws -> [APIMatch] {
        let endpoint = "team/\(key)/matches/\(year)"
        return try await fetch(endpoint)
    }

    public func teamMatches(key: String, eventKey: String) async throws -> [APIMatch] {
        let endpoint = "team/\(key)/event/\(eventKey)/matches"
        return try await fetch(endpoint)
    }

    public func teamAwards(key: String, year: Int? = nil) async throws -> [APIAward] {
        var endpoint = "team/\(key)/awards"
        if let year = year {
            endpoint = "\(endpoint)/\(year)"
        }
        return try await fetch(endpoint)
    }

    public func teamAwards(key: String, eventKey: String) async throws -> [APIAward] {
        let endpoint = "team/\(key)/event/\(eventKey)/awards"
        return try await fetch(endpoint)
    }

    public func teamMedia(key: String, year: Int) async throws -> [APIMedia] {
        let endpoint = "team/\(key)/media/\(year)"
        return try await fetch(endpoint)
    }

    public func teamSocialMedia(key: String) async throws -> [APIMedia] {
        let endpoint = "team/\(key)/social_media"
        return try await fetch(endpoint)
    }

}
