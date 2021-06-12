//
//  TBAKit+District.swift
//  
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

extension TBAKit {

    public func districts(year: Int) async throws -> [APIDistrict] {
        let endpoint = "districts/\(year)"
        return try await fetch(endpoint)
    }

    public func districtEvents(key: String) async throws -> [APIEvent] {
        let endpoint = "district/\(key)/events"
        return try await fetch(endpoint)
    }

    public func districtTeams(key: String) async throws -> [APITeam] {
        let endpoint = "district/\(key)/teams"
        return try await fetch(endpoint)
    }


    public func districtRankings(key: String) async throws -> [APIDistrictRanking] {
        let endpoint = "district/\(key)/rankings"
        return try await fetch(endpoint)
    }

}
