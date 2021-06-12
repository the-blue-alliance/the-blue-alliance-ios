//
//  APIWLT.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct APIWLT: Decodable {
    public let wins: Int
    public let losses: Int
    public let ties: Int
}
