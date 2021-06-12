//
//  APIAlliance.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct APIAlliance: Decodable {
    public let name: String?
    public let backup: APIAllianceBackup?
    public let declines: [String]?
    public let picks: [String]
    public let status: APIAllianceStatus?
}

public struct APIAllianceStatus: Decodable {
    public let currentRecord: APIWLT?
    public let level: String?
    public let playoffAverage: Double?
    public let record: APIWLT?
    public let status: String?

    enum CodingKeys: String, CodingKey {
        case currentRecord = "current_level_record"
        case level
        case playoffAverage = "playoff_average"
        case record
        case status
    }
}


public struct APIAllianceBackup: Decodable {
    public let teamKeyIn: String
    public let teamKeyOut: String

    enum CodingKeys: String, CodingKey {
        case teamKeyIn = "in"
        case teamKeyOut = "out"
    }
}
