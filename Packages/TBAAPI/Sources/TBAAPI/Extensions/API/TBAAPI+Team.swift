//
//  TBAAPI+Team.swift
//  TBAAPI
//
//  Created by Zachary Orr on 11/9/24.
//

extension TBAAPI {
    public func getTeamsSimple(pageNumber: Int) async throws -> [Team] {
        let response = try await client.getTeamsSimple(path: .init(page_num: pageNumber))
        return try convertResponse(response: response.ok.body.json)
    }

    public func getTeamSimple(teamKey: TeamKey) async throws -> Team {
        let response = try await client.getTeamSimple(path: .init(team_key: teamKey))
        return try convertResponse(response: response.ok.body.json)
    }
}
