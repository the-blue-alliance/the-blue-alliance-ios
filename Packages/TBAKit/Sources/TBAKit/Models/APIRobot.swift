//
//  APIRobot.swift
//  
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIRobot: Decodable {
    public let key: String
    public let name: String
    public let teamKey: String
    public let year: Int

    enum CodingKeys: String, CodingKey {
        case key
        case name = "robot_name"
        case teamKey = "team_key"
        case year
    }
}
