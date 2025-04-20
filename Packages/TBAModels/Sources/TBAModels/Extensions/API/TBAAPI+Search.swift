//
//  TBAAPI+Search.swift
//  TBAModels
//
//  Created by Zachary Orr on 4/19/25.
//

import TBAAPI

extension TBAAPI {
    public func getSearchIndex() async throws -> SearchIndex {
        let response = try await client.getSearchIndex()
        return try convertResponse(response: response.ok.body.json)
    }
}
