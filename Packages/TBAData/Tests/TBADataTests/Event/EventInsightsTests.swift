import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventInsightsTestCase: TBADataTestCase {

    func test_playoff() {
        let insights = EventInsights.init(entity: EventInsights.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(insights.playoff)
        insights.playoffRaw = ["abc": 1]
        XCTAssertEqual(insights.playoff as! [String : Int], ["abc": 1])
    }

    func test_qual() {
        let insights = EventInsights.init(entity: EventInsights.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(insights.qual)
        insights.qualRaw = ["abc": 1]
        XCTAssertEqual(insights.qual as! [String : Int], ["abc": 1])
    }

    func test_event() {
        let insights = EventInsights.init(entity: EventInsights.entity(), insertInto: persistentContainer.viewContext)
        let event = insertEvent()
        insights.eventRaw = event
        XCTAssertEqual(insights.event, event)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventInsights> = EventInsights.fetchRequest()
        XCTAssertEqual(fr.entityName, EventInsights.entityName)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let model = TBAEventInsights(qual: ["abc": 2], playoff: ["def": 3])
        let insights = EventInsights.insert(model, eventKey: event.key, in: persistentContainer.viewContext)

        XCTAssertEqual(insights.qual as! [String: Int], ["abc": 2])
        XCTAssertEqual(insights.playoff as! [String: Int], ["def": 3])

        // Should fail - Insights must be attached to an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        insights.eventRaw = event
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let modelOne = TBAEventInsights(qual: ["abc": 2], playoff: ["def": 3])
        let insightsOne = EventInsights.insert(modelOne, eventKey: event.key, in: persistentContainer.viewContext)
        insightsOne.eventRaw = event

        let modelTwo = TBAEventInsights(qual: nil, playoff: nil)
        let insightsTwo = EventInsights.insert(modelTwo, eventKey: event.key, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(insightsOne, insightsTwo)

        XCTAssertNil(insightsOne.qual)
        XCTAssertNil(insightsOne.playoff)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let model = TBAEventInsights(qual: ["abc": 2], playoff: ["def": 3])
        let insights = EventInsights.insert(model, eventKey: event.key, in: persistentContainer.viewContext)
        insights.eventRaw = event

        persistentContainer.viewContext.delete(insights)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Event should not be deleted
        XCTAssertNotNil(event.managedObjectContext)
    }

    func test_isOrphaned() {
        let insights = EventInsights.init(entity: EventInsights.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(insights.isOrphaned)

        insights.eventRaw = insertDistrictEvent()
        XCTAssertFalse(insights.isOrphaned)
        insights.eventRaw = nil

        XCTAssert(insights.isOrphaned)
    }

    func test_insightsDictionary() {
        let insights = EventInsights.init(entity: EventInsights.entity(), insertInto: persistentContainer.viewContext)

        insights.qualRaw = ["abc": 1]
        XCTAssertEqual(insights.insightsDictionary as! [String : [String : Int]], ["qual": ["abc": 1]])

        insights.playoffRaw = ["def": 2]
        XCTAssertEqual(insights.insightsDictionary as! [String : [String : Int]], ["qual": ["abc": 1], "playoff": ["def": 2]])

        insights.qualRaw = nil
        XCTAssertEqual(insights.insightsDictionary as! [String : [String : Int]], ["playoff": ["def": 2]])
    }

}
