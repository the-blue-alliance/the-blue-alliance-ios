//
//  Sorted.swift
//  TBAAPI
//
//  Created by Zachary Orr on 11/10/24.
//

import Foundation

@propertyWrapper
public struct SortedKeyPath<Value> {
    public var wrappedValue: [Value]? {
        didSet {
            wrappedValue?.sort(using: comparators)
        }
    }

    public let comparators: [KeyPathComparator<Value>]

    public init(wrappedValue: [Value]?, comparator: KeyPathComparator<Value>) {
        self.init(wrappedValue: wrappedValue, comparators: [comparator])
    }

    public init(wrappedValue: [Value]?, comparators: [KeyPathComparator<Value>]) {
        self.wrappedValue = wrappedValue?.sorted(using: comparators)
        self.comparators = comparators
    }
}

extension SortedKeyPath: Equatable where Value: Equatable {
    public static func == (lhs: SortedKeyPath<Value>, rhs: SortedKeyPath<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}
