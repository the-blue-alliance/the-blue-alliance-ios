//
//  TBAAPI-main.swift
//
//
//  Created by Zachary Orr on 8/15/24.
//

import Foundation
import TBAAPI

let api = TBAAPI(apiKey: "")
let response = try await api.client.getEventsByYear(path: .init(year: 2025))
print(try! response.ok.body.json)