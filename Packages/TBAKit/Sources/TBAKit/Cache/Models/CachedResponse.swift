//
//  CachedResponse.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public struct CachedResponse: Codable, Equatable {
    let url: URL
    let lastModified: String
    let etag: String
    let data: Data
}
