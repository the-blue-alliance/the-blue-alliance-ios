//
//  APIMedia.swift
//  
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct APIMedia: Decodable {
    public var type: String
    public var foreignKey: String
    public var details: [String: Any]?
    public var preferred: Bool
    public var directURL: String?
    public var viewURL: String?

    enum CodingKeys: String, CodingKey {
        case type
        case foreignKey = "foreign_key"
        case details
        case preferred
        case directURL = "direct_url"
        case viewURL = "view_url"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        type = try values.decode(String.self, forKey: .type)
        foreignKey = try values.decode(String.self, forKey: .foreignKey)
        details = try values.decodeIfPresent([String: Any].self, forKey: .details)
        preferred = try values.decode(Bool.self, forKey: .preferred)
        directURL = try values.decodeIfPresent(String.self, forKey: .directURL)
        viewURL = try values.decodeIfPresent(String.self, forKey: .viewURL)
    }
}
