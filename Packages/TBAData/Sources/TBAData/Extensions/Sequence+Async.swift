//
//  Sequence+Async.swift
//  
//
//  Created by Zachary Orr on 5/28/22.
//

import Foundation

// TODO: Update this with async map in iOS 16
extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}

