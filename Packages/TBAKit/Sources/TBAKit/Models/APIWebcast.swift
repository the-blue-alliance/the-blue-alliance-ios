//
//  APIWebcast.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct APIWebcast: Decodable {
    public let type: String
    public let channel: String
    public let file: String?
    public let date: Date?
}
