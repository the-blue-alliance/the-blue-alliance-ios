//
//  APIWLT.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct APIWLT: Decodable {
    public var wins: Int
    public var losses: Int
    public var ties: Int
}
