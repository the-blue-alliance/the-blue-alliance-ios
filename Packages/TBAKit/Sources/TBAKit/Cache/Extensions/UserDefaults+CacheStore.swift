//
//  UserDefaults+CacheStore.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

internal let kCacheKey = "kTBAKitCacheKey"
typealias CacheDictionary = [String: Data]

extension UserDefaults: CacheStore {

    public func get(forURL url: URL) -> CachedResponse? {
        let cacheDictionary = dictionary(forKey: kCacheKey) as? CacheDictionary ?? [:]
        guard let encodedCache = cacheDictionary[url.absoluteString] else {
            return nil
        }
        return try? decode(encodedCache)
    }

    public func set(_ response: CachedResponse, forURL url: URL) {
        var cacheDictionary = dictionary(forKey: kCacheKey) as? CacheDictionary ?? [:]
        guard let encodedResponse = try? encode(response) else {
            return
        }
        cacheDictionary[url.absoluteString] = encodedResponse
        set(cacheDictionary, forKey: kCacheKey)
    }

    public func clear() {
        removeObject(forKey: kCacheKey)
    }

    private func encode(_ response: CachedResponse) throws -> Data {
        let encoder = PropertyListEncoder()
        return try encoder.encode(response)
    }

    private func decode(_ data: Data) throws -> CachedResponse {
        let decoder = PropertyListDecoder()
        return try decoder.decode(CachedResponse.self, from: data)
    }

}
