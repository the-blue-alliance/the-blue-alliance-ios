//
//  APIWebcast.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct APIWebcast: Decodable {
    public var type: String
    public var channel: String
    public var file: String?
    public var date: Date?
}
