import TBAData
import XCTest

class EventKeyTestCase: TBADataTestCase {

    func test_insert_required() {
        let eventKey = EventKey.init(entity: EventKey.entity(), insertInto: viewContext)
        XCTAssertThrowsError(try viewContext.save())
        eventKey.key = "2018miket"
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_insert() {
        let testEventKey = "2018miket"

        let eventKey_first = EventKey.insert(withKey: testEventKey, in: viewContext)
        XCTAssertNotNil(eventKey_first)
        XCTAssertEqual(eventKey_first.key, testEventKey)

        let eventKey_second = EventKey.insert(withKey: testEventKey, in: viewContext)
        XCTAssertEqual(eventKey_first, eventKey_second)
    }

    func test_event() {
        let eventKey = EventKey.insert(withKey: "2018miket", in: viewContext)
        XCTAssertNil(eventKey.event)

        let event = coreDataTestFixture.insertDistrictEvent()
        XCTAssertNotNil(eventKey.event)
        XCTAssertEqual(eventKey.event, event)
    }

    func test_isOrphaned() {
        let eventKey = EventKey.init(entity: EventKey.entity(), insertInto: viewContext)
        // EventKey should never be orphaned
        XCTAssertFalse(eventKey.isOrphaned)
    }

}
