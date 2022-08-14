//
//  TBACacheStore.swift
//  
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation

public protocol TBACacheStore {
    func get(forURL url: URL) -> TBACachedResponse?
    func set(_ value: TBACachedResponse, forURL url: URL)
    func clear()
}
