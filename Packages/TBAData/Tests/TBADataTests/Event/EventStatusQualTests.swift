import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventStatusQualTestCase: TBADataTestCase {

    func test_numTeams() {
        let status = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.numTeams)
        status.numTeamsRaw = NSNumber(value: 2)
        XCTAssertEqual(status.numTeams, 2)
    }

    func test_status() {
        let status = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.status)
        status.statusRaw = "status"
        XCTAssertEqual(status.status, "status")
    }

    func test_eventStatus() {
        let status = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.eventStatus)
        let eventStatus = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        status.eventStatusRaw = eventStatus
        XCTAssertEqual(status.eventStatus, eventStatus)
    }

    func test_ranking() {
        let status = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.eventStatus)
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        status.rankingRaw = ranking
        XCTAssertEqual(status.ranking, ranking)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventStatusQual> = EventStatusQual.fetchRequest()
        XCTAssertEqual(fr.entityName, EventStatusQual.entityName)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let model = TBAEventStatusQual(numTeams: 3, status: "playing", ranking: nil, sortOrder: nil)
        let status = EventStatusQual.insert(model, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        XCTAssertEqual(status.numTeams, 3)
        XCTAssertEqual(status.status, "playing")
        XCTAssertNil(status.ranking)

        // Should save fine - qual status doesn't need to be attached to an EventStatus or a Ranking
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insertPredicate() {
        let event = insertDistrictEvent()
        let teamKey = "frc1"

        let model = TBAEventStatusQual(numTeams: nil, status: nil, ranking: nil, sortOrder: nil)
        let status = EventStatusQual.init(entity: EventStatusQual.entity(), insertInto: persistentContainer.viewContext)

        // Test inserting EventStatusQual.ranking.teamKey.key == eventKey
        let ranking = EventRanking.init(entity: EventRanking.entity(), insertInto: persistentContainer.viewContext)
        ranking.teamRaw = Team.insert(teamKey, in: persistentContainer.viewContext)
        ranking.eventRaw = event
        ranking.qualStatusRaw = status

        XCTAssertEqual(EventStatusQual.insert(model, eventKey: event.key, teamKey: teamKey, in: persistentContainer.viewContext), status)

        persistentContainer.viewContext.delete(ranking)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Test inserting EventStatusQual.eventStatus.event.key == eventKey
        let eventStatus = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        eventStatus.teamRaw = Team.insert(teamKey, in: persistentContainer.viewContext)
        eventStatus.eventRaw = event
        eventStatus.qualRaw = status

        XCTAssertEqual(EventStatusQual.insert(model, eventKey: event.key, teamKey: teamKey, in: persistentContainer.viewContext), status)
    }

    func test_update() {
        let event = insertDistrictEvent()

        let modelOne = TBAEventStatusQual(numTeams: 3, status: "playing", ranking: TBAEventRanking(teamKey: "frc1", rank: 3), sortOrder: nil)
        let statusOne = EventStatusQual.insert(modelOne, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        let ranking = statusOne.ranking!
        ranking.eventRaw = event

        let modelTwo = TBAEventStatusQual(numTeams: 4, status: "not playing", ranking: nil, sortOrder: nil)
        let statusTwo = EventStatusQual.insert(modelTwo, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(statusOne, statusTwo)

        // Check we updated properly
        XCTAssertEqual(statusOne.numTeams, 4)
        XCTAssertEqual(statusOne.status, "not playing")
        XCTAssertNil(statusOne.ranking)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ranking should not be deleted - it's attached to an Event
        XCTAssertNotNil(ranking.managedObjectContext)
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let model = TBAEventStatusQual(numTeams: 3, status: "playing", ranking: TBAEventRanking(teamKey: "frc1", rank: 3), sortOrder: nil)
        let status = EventStatusQual.insert(model, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        let ranking = status.ranking!
        ranking.eventRaw = event

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Don't allow deletion while attached to a Ranking
        persistentContainer.viewContext.delete(status)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        persistentContainer.viewContext.rollback()
        status.rankingRaw = nil

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let eventStatusModel = TBAEventStatus(teamKey: "frc1", eventKey: event.key)
        let eventStatus = EventStatus.insert(eventStatusModel, in: persistentContainer.viewContext)
        eventStatus.eventRaw = event
        eventStatus.qualRaw = status

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Don't allow deletion while attached to an Event Status
        persistentContainer.viewContext.delete(status)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        persistentContainer.viewContext.rollback()
        eventStatus.qualRaw = nil

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Should delete fine
        persistentContainer.viewContext.delete(status)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ranking and EventStatus should not be deleted - it's attached to an Event
        XCTAssertNotNil(ranking.managedObjectContext)
        XCTAssertNotNil(eventStatus.managedObjectContext)
    }

}
