//
//  TBAModels+Convert.swift
//  TBAModels
//
//  Created by Zachary Orr on 4/19/25.
//

import Foundation
import TBAAPI

func convertResponse<Z: Encodable, O: Decodable>(response: Z) throws -> O {
    let encoder = JSONEncoder()
    let encoded = try encoder.encode(response)

    let decoder = JSONDecoder()
    // Note to Zach: If we ever need performance here, avoiding the date conversion
    // in testing for a full year of Events saves us ~20ms (out of like ~30ms)
    decoder.dateDecodingStrategy = .formatted(TBAAPI.dateFormatter)
    return try decoder.decode(O.self, from: encoded)
}
