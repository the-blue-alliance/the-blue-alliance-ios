//
//  TBAAPI+District.swift
//  TBAAPI
//
//  Created by Zachary Orr on 11/9/24.
//

extension TBAAPI {
    public func getDistricts(year: Year) async throws -> [District] {
        let response = try await client.getDistrictsByYear(path: .init(year: year))
        return try convertResponse(response: response.ok.body.json)
    }

    public func getDistrictEvents(districtKey: DistrictKey) async throws -> [Event] {
        let response = try await client.getDistrictEvents(path: .init(district_key: districtKey))
        return try convertResponse(response: response.ok.body.json)
    }

    public func getDistrictTeamsSimple(districtKey: DistrictKey) async throws -> [Team] {
        let response = try await client.getDistrictTeamsSimple(path: .init(district_key: districtKey))
        return try convertResponse(response: response.ok.body.json)
    }

    public func getDistrictTeams(districtKey: DistrictKey) async throws -> [Team] {
        let response = try await client.getDistrictTeams(path: .init(district_key: districtKey))
        return try convertResponse(response: response.ok.body.json)
    }

    public func getDistrictRankings(districtKey: DistrictKey) async throws -> [DistrictRanking] {
        let response = try await client.getDistrictRankings(path: .init(district_key: districtKey))
        return try convertResponse(response: response.ok.body.json)
    }
}
