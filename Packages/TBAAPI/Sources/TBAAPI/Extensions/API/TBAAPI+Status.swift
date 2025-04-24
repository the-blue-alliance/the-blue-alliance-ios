//
//  TBAAPI+Status.swift
//
//
//  Created by Zachary Orr on 8/15/24.
//

extension TBAAPI {
    public func getStatus() async throws -> Components.Schemas.API_Status {
        let response = try await client.getStatus()
        return try convertResponse(response: response.ok.body.json)
    }
}
