//
//  APIAward.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct APIAward: Decodable {
    public let name: String
    public let awardType: Int
    public let eventKey: String
    public let recipients: [APIAwardRecipient]
    public let year: Int

    enum CodingKeys: String, CodingKey {
        case name
        case awardType = "award_type"
        case eventKey = "event_key"
        case recipients = "recipient_list"
        case year
    }
}

public struct APIAwardRecipient: Decodable {
    // The TBA team key for the team that was given the award. May be null
    public let teamKey: String?
    // The name of the individual given the award. May be null
    public let awardee: String?

    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case awardee
    }
}
