//
//  TBAPersistenceContainerTests.swift
//  
//
//  Created by Zachary Orr on 5/27/22.
//

import CoreData
import Foundation
import XCTest
import TBAData2

class TBAPersistenceContainerTests: XCTest {

    func test_init() {
        let persistenceContainer = TBAPersistenceContainer()
        XCTAssertEqual(persistenceContainer.name, "TBA")
    }

    func test_backgroundContext() {
        let persistenceContainer = TBAPersistenceContainer()
        let context = persistenceContainer.newBackgroundContext()

        let mergePolicy = context.mergePolicy as! NSMergePolicy
        XCTAssertEqual(mergePolicy.mergeType, .mergeByPropertyObjectTrumpMergePolicyType)
    }

}
