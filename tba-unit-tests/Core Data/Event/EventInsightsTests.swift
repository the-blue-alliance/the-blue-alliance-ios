import TBAKit
import XCTest
@testable import The_Blue_Alliance

class EventInsightsTestCase: CoreDataTestCase {

    func test_insert() {
        let event = districtEvent()

        let model = TBAEventInsights(qual: ["abc": 2], playoff: ["def": 3])
        let insights = EventInsights.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)

        XCTAssertEqual(insights.qual as! [String: Int], ["abc": 2])
        XCTAssertEqual(insights.playoff as! [String: Int], ["def": 3])

        // Should fail - Insights must be attached to an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        insights.event = event
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = districtEvent()

        let modelOne = TBAEventInsights(qual: ["abc": 2], playoff: ["def": 3])
        let insightsOne = EventInsights.insert(modelOne, eventKey: event.key!, in: persistentContainer.viewContext)
        insightsOne.event = event

        let modelTwo = TBAEventInsights(qual: nil, playoff: nil)
        let insightsTwo = EventInsights.insert(modelTwo, eventKey: event.key!, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(insightsOne, insightsTwo)

        XCTAssertNil(insightsOne.qual)
        XCTAssertNil(insightsOne.playoff)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete() {
        let event = districtEvent()

        let model = TBAEventInsights(qual: ["abc": 2], playoff: ["def": 3])
        let insights = EventInsights.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)
        insights.event = event

        persistentContainer.viewContext.delete(insights)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Event should not be deleted
        XCTAssertNotNil(event.managedObjectContext)
    }

}
