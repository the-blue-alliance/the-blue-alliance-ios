//
//  TBAAPI+Search.swift
//  TBAModels
//
//  Created by Zachary Orr on 4/19/25.
//

extension TBAAPI {
    public func getSearchIndex() async throws -> Components.Schemas.SearchIndex {
        let response = try await client.getSearchIndex()
        return try response.ok.body.json
        // return try convertResponse(response: response.ok.body.json)
    }
}
