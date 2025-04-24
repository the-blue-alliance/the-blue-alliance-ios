//
//  District.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct District: Decodable {
    public var abbreviation: String
    public var name: String
    public var key: String
    public var year: Int

    public init(abbreviation: String, name: String, key: String, year: Int) {
        self.abbreviation = abbreviation
        self.name = name
        self.key = key
        self.year = year
    }

    enum CodingKeys: String, CodingKey {
        case abbreviation
        case name = "display_name"
        case key
        case year
    }
}

extension District: Equatable, Hashable, Sendable {}
