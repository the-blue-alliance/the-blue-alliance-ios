//
//  CachedResponse.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct TBACachedResponse: Codable, Equatable {
    let url: URL
    let date: Date
    let etag: String
    let data: Data
}
