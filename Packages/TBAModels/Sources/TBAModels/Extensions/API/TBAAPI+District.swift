//
//  TBAAPI+District.swift
//  TBAAPI
//
//  Created by Zachary Orr on 11/9/24.
//

import TBAAPI

extension TBAAPI {
    public func getDistricts(year: Year) async throws -> [District] {
        let response = try await client.getDistrictsByYear(path: .init(year: year))
        return try convertResponse(response: response.ok.body.json)
    }
}
