//
//  APIEventStats.swift
//
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIEventStats: Decodable {
    public var ccwms: [String: Double]
    public var dprs: [String: Double]
    public var oprs: [String: Double]

    enum CodingKeys: String, CodingKey {
        case ccwms
        case dprs
        case oprs
    }
}
