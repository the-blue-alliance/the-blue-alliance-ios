//
//  Cache+TBA.swift
//  
//
//  Created by Zachary Orr on 5/27/22.
//

import Foundation

typealias TBACache = Cache<URL, TBACachedResponse>

extension TBACache: TBACacheStore {

    func get(forURL url: URL) -> TBACachedResponse? {
        return self[url]
    }

    func set(_ value: TBACachedResponse, forURL url: URL) {
        self[url] = value
    }

    func clear() {
        removeAll()
    }

}
