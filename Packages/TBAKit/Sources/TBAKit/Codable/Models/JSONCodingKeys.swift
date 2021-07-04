//
//  JSONCodingKeys.swift
//  
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

public struct JSONCodingKeys: CodingKey {
    public var stringValue: String

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public var intValue: Int?

    public init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
