import XCTest
@testable import TBA

class EventKeyTestCase: CoreDataTestCase {

    func test_insert_required() {
        let eventKey = EventKey.init(entity: EventKey.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        eventKey.key = "2018miket"
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert() {
        let testEventKey = "2018miket"

        let eventKey_first = EventKey.insert(withKey: testEventKey, in: persistentContainer.viewContext)
        XCTAssertNotNil(eventKey_first)
        XCTAssertEqual(eventKey_first.key, testEventKey)

        let eventKey_second = EventKey.insert(withKey: testEventKey, in: persistentContainer.viewContext)
        XCTAssertEqual(eventKey_first, eventKey_second)
    }

    func test_event() {
        let eventKey = EventKey.insert(withKey: "2018miket", in: persistentContainer.viewContext)
        XCTAssertNil(eventKey.event)

        let event = insertDistrictEvent()
        XCTAssertNotNil(eventKey.event)
        XCTAssertEqual(eventKey.event, event)
    }

    func test_isOrphaned() {
        let eventKey = EventKey.init(entity: EventKey.entity(), insertInto: persistentContainer.viewContext)
        // EventKey should never be orphaned
        XCTAssertFalse(eventKey.isOrphaned)
    }

}
