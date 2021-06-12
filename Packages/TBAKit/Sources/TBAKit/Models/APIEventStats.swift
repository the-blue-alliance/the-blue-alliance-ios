//
//  APIEventStats.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIEventStats: Decodable {
    public let ccwms: [String: Double]
    public let dprs: [String: Double]
    public let oprs: [String: Double]

    enum CodingKeys: String, CodingKey {
        case ccwms
        case dprs
        case oprs
    }
}
