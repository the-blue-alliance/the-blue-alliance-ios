import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventStatusPlayoffTestCase: TBADataTestCase {

    func test_currentRecord() {
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.currentRecord)
        let wlt = WLT(wins: 1, losses: 2, ties: 3)
        status.currentRecordRaw = wlt
        XCTAssertEqual(status.currentRecord, wlt)
    }

    func test_level() {
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.level)
        status.levelRaw = "level"
        XCTAssertEqual(status.level, "level")
    }

    func test_playoffAverage() {
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.playoffAverage)
        status.playoffAverageRaw = NSNumber(value: 2.34)
        XCTAssertEqual(status.playoffAverage, 2.34)
    }

    func test_record() {
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.record)
        let wlt = WLT(wins: 1, losses: 2, ties: 3)
        status.recordRaw = wlt
        XCTAssertEqual(status.record, wlt)
    }

    func test_status() {
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.status)
        status.statusRaw = "status"
        XCTAssertEqual(status.status, "status")
    }

    func test_eventStatus() {
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.eventStatus)
        let eventStatus = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        status.eventStatusRaw = eventStatus
        XCTAssertEqual(status.eventStatus, eventStatus)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventStatusPlayoff> = EventStatusPlayoff.fetchRequest()
        XCTAssertEqual(fr.entityName, EventStatusPlayoff.entityName)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let model = TBAAllianceStatus(currentRecord: TBAWLT(wins: 1, losses: 2, ties: 3), level: "level", playoffAverage: 2.22, record: TBAWLT(wins: 2, losses: 2, ties: 3), status: "status")
        let status = EventStatusPlayoff.insert(model, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        XCTAssertNotNil(status.currentRecord)
        XCTAssertEqual(status.level, "level")
        XCTAssertEqual(status.playoffAverage, 2.22)
        XCTAssertNotNil(status.record)
        XCTAssertEqual(status.status, "status")

        // Should not fail - should be able to save without Alliance or EventStatus
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insertPredicate() {
        let event = insertDistrictEvent()
        let teamKey = "frc1"

        let model = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        var status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)

        // Test inserting an EventStatus where EventStatusPlayoff.eventStatus.event.key == eventKey
        let eventStatus = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        eventStatus.teamRaw = Team.insert(teamKey, in: persistentContainer.viewContext)
        eventStatus.eventRaw = event
        eventStatus.playoffRaw = status

        XCTAssertEqual(EventStatusPlayoff.insert(model, eventKey: event.key, teamKey: teamKey, in: persistentContainer.viewContext), status)

        persistentContainer.viewContext.delete(eventStatus)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)

        // Test inserting an EventAlliance where teamKey is in picks
        let modelAlliance = TBAAlliance(name: nil, backup: nil, declines: nil, picks: ["frc1"], status: TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil))
        let alliance = EventAlliance.insert(modelAlliance, eventKey: event.key, in: persistentContainer.viewContext)
        alliance.statusRaw = status
        alliance.eventRaw = event

        XCTAssertEqual(EventStatusPlayoff.insert(model, eventKey: event.key, teamKey: teamKey, in: persistentContainer.viewContext), status)
    }

    func test_update() {
        let event = insertDistrictEvent()

        let modelAlliance = TBAAlliance(name: nil, backup: nil, declines: nil, picks: ["frc1"], status: nil)
        let alliance = EventAlliance.insert(modelAlliance, eventKey: event.key, in: persistentContainer.viewContext)
        alliance.eventRaw = event

        let modelOne = TBAAllianceStatus(currentRecord: TBAWLT(wins: 1, losses: 2, ties: 3), level: "level", playoffAverage: 2.22, record: TBAWLT(wins: 2, losses: 2, ties: 3), status: "status")
        let statusOne = EventStatusPlayoff.insert(modelOne, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)
        statusOne.allianceRaw = alliance

        let modelTwo = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let statusTwo = EventStatusPlayoff.insert(modelTwo, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(statusOne, statusTwo)

        XCTAssertNil(statusOne.currentRecord)
        XCTAssertNil(statusOne.playoffAverage)
        XCTAssertNil(statusOne.level)
        XCTAssertNil(statusOne.record)
        XCTAssertNil(statusOne.status)
    }

    // This is a good example of how we should be testing deletes
    func test_delete() {
        let event = insertDistrictEvent()

        let model = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let status = EventStatusPlayoff.insert(model, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        let modelAlliance = TBAAlliance(name: nil, backup: nil, declines: nil, picks: ["frc1"], status: TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil))
        let alliance = EventAlliance.insert(modelAlliance, eventKey: event.key, in: persistentContainer.viewContext)
        alliance.statusRaw = status
        alliance.eventRaw = event

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Should not delete when attached to an Alliance
        persistentContainer.viewContext.delete(status)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        persistentContainer.viewContext.rollback()
        alliance.statusRaw = nil

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let modelStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key)
        let eventStatus = EventStatus.insert(modelStatus, in: persistentContainer.viewContext)
        eventStatus.playoffRaw = status
        eventStatus.eventRaw = event

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Should not delete when attached to an EventStatus
        persistentContainer.viewContext.delete(status)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        persistentContainer.viewContext.rollback()
        eventStatus.playoffRaw = nil

        // Should delete fine
        persistentContainer.viewContext.delete(status)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_allianceLevel() {
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        // No level - should be nil
        XCTAssertNil(status.allianceLevel)

        // Not a final
        status.levelRaw = "sf"
        XCTAssertEqual(status.allianceLevel, "SF")

        // A final loss
        status.statusRaw = "lost"
        status.levelRaw = "f"
        XCTAssertEqual(status.allianceLevel, "F")

        // A final win
        status.statusRaw = "won"
        status.levelRaw = "f"
        XCTAssertEqual(status.allianceLevel, "W")
    }

}
