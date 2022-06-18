//
//  APIAlliance.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct APIAlliance: Decodable {
    public var name: String?
    public var backup: APIAllianceBackup?
    public var declines: [String]?
    public var picks: [String]
    public var status: APIAllianceStatus?
}

public struct APIAllianceStatus: Decodable {
    public var currentRecord: APIWLT?
    public var level: String?
    public var playoffAverage: Double?
    public var record: APIWLT?
    public var status: String?

    enum CodingKeys: String, CodingKey {
        case currentRecord = "current_level_record"
        case level
        case playoffAverage = "playoff_average"
        case record
        case status
    }
}


public struct APIAllianceBackup: Decodable {
    public var teamKeyIn: String
    public var teamKeyOut: String

    enum CodingKeys: String, CodingKey {
        case teamKeyIn = "in"
        case teamKeyOut = "out"
    }
}
