//
//  CacheStore.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public protocol CacheStore {
    func get(forURL url: URL) -> CachedResponse?
    func set(_ value: CachedResponse, forURL url: URL)
    func clear()
}
