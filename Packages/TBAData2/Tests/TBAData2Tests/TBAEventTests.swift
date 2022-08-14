//
//  TBAEventTests.swift
//  
//
//  Created by Zachary Orr on 5/27/22.
//

import CoreData
import TBAKit
import XCTest
@testable import TBAData2

class TBAEventTestCase: TBADataTestCase {

    func testEntityAttributeTypes(entityName: String) {
        let entity = persistentContainer.managedObjectModel.entitiesByName["TBAEvent"]!
        verifyAttribute(named: "address", on: entity, hasType: .string)
        verifyAttribute(named: "city", on: entity, hasType: .string)
        verifyAttribute(named: "country", on: entity, hasType: .string)
        verifyAttribute(named: "divisionKeys", on: entity, hasType: .transformable)
        verifyAttribute(named: "endDate", on: entity, hasType: .date)
        verifyAttribute(named: "eventCode", on: entity, hasType: .string)
        verifyAttribute(named: "eventType", on: entity, hasType: .integer16)
        verifyAttribute(named: "eventTypeString", on: entity, hasType: .string)
        verifyAttribute(named: "firstEventCode", on: entity, hasType: .string)
        verifyAttribute(named: "firstEventID", on: entity, hasType: .string)
        verifyAttribute(named: "gmapsPlaceID", on: entity, hasType: .string)
        verifyAttribute(named: "gmapsURL", on: entity, hasType: .string)
        verifyAttribute(named: "key", on: entity, hasType: .string)
        verifyAttribute(named: "lat", on: entity, hasType: .double)
        verifyAttribute(named: "lng", on: entity, hasType: .double)
        verifyAttribute(named: "locationName", on: entity, hasType: .string)
        verifyAttribute(named: "name", on: entity, hasType: .string)
        verifyAttribute(named: "parentEventKey", on: entity, hasType: .string)
        verifyAttribute(named: "playoffType", on: entity, hasType: .integer16)
        verifyAttribute(named: "playoffTypeString", on: entity, hasType: .string)
        verifyAttribute(named: "postalCode", on: entity, hasType: .string)
        verifyAttribute(named: "shortName", on: entity, hasType: .string)
        verifyAttribute(named: "startDate", on: entity, hasType: .date)
        verifyAttribute(named: "stateProv", on: entity, hasType: .string)
        verifyAttribute(named: "timezone", on: entity, hasType: .string)
        verifyAttribute(named: "website", on: entity, hasType: .string)
        verifyAttribute(named: "week", on: entity, hasType: .integer16)
        verifyAttribute(named: "year", on: entity, hasType: .integer64)
    }

    // TODO: parentEventKey -> parentEvent + a basically empty Event object?
    // TODO: Make sure "divisionKeys" round trips properly

}
