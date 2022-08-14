//
//  TBADataTestCase.swift
//  
//
//  Created by Zachary Orr on 5/27/22.
//

import CoreData
import XCTest
import TBAData2 // TODO: Rename

class TBADataTestCase: XCTestCase {

    var persistentContainer: TBAPersistenceContainer!

    override class func setUp() {
        super.setUp()
    }

    func verifyAttribute(named name: String, on entity: NSEntityDescription, hasType type: NSAttributeDescription.AttributeType) {
        guard let attribute = entity.attributesByName[name] else {
            XCTFail("\(entity.name!) is missing expected attribute \(name)")
            return
        }
        XCTAssertEqual(type, attribute.type)
    }

}
