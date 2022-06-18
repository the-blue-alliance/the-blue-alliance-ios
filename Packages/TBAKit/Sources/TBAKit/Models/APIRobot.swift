//
//  APIRobot.swift
//  
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIRobot: Decodable {
    public var key: String
    public var name: String
    public var teamKey: String
    public var year: Int

    enum CodingKeys: String, CodingKey {
        case key
        case name = "robot_name"
        case teamKey = "team_key"
        case year
    }
}
