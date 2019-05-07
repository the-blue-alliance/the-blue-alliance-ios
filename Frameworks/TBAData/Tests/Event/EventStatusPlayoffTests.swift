import TBAData
import TBAKit
import XCTest

class EventStatusPlayoffTestCase: TBADataTestCase {

    func test_insert() {
        let event = coreDataTestFixture.insertDistrictEvent()

        let model = TBAAllianceStatus(currentRecord: TBAWLT(wins: 1, losses: 2, ties: 3), level: "level", playoffAverage: 2.22, record: TBAWLT(wins: 2, losses: 2, ties: 3), status: "status")
        let status = EventStatusPlayoff.insert(model, eventKey: event.key!, teamKey: "frc1", in: viewContext)

        XCTAssertNotNil(status.currentRecord)
        XCTAssertEqual(status.level, "level")
        XCTAssertEqual(status.playoffAverage, 2.22)
        XCTAssertNotNil(status.record)
        XCTAssertEqual(status.status, "status")

        // Should not fail - should be able to save without Alliance or EventStatus
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_insertPredicate() {
        let event = coreDataTestFixture.insertDistrictEvent()
        let teamKey = "frc1"

        let model = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        var status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: viewContext)

        // Test inserting an EventStatus where EventStatusPlayoff.eventStatus.event.key == eventKey
        let eventStatus = EventStatus.init(entity: EventStatus.entity(), insertInto: viewContext)
        eventStatus.teamKey = TeamKey.insert(withKey: teamKey, in: viewContext)
        eventStatus.event = event
        eventStatus.playoff = status

        XCTAssertEqual(EventStatusPlayoff.insert(model, eventKey: event.key!, teamKey: teamKey, in: viewContext), status)

        viewContext.delete(eventStatus)
        XCTAssertNoThrow(try viewContext.save())

        status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: viewContext)

        // Test inserting an EventAlliance where teamKey is in picks
        let modelAlliance = TBAAlliance(name: nil, backup: nil, declines: nil, picks: ["frc1"], status: TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil))
        let alliance = EventAlliance.insert(modelAlliance, eventKey: event.key!, in: viewContext)
        alliance.status = status
        alliance.event = event

        XCTAssertEqual(EventStatusPlayoff.insert(model, eventKey: event.key!, teamKey: teamKey, in: viewContext), status)
    }

    func test_update() {
        let event = coreDataTestFixture.insertDistrictEvent()

        let modelAlliance = TBAAlliance(name: nil, backup: nil, declines: nil, picks: ["frc1"], status: nil)
        let alliance = EventAlliance.insert(modelAlliance, eventKey: event.key!, in: viewContext)
        alliance.event = event

        let modelOne = TBAAllianceStatus(currentRecord: TBAWLT(wins: 1, losses: 2, ties: 3), level: "level", playoffAverage: 2.22, record: TBAWLT(wins: 2, losses: 2, ties: 3), status: "status")
        let statusOne = EventStatusPlayoff.insert(modelOne, eventKey: event.key!, teamKey: "frc1", in: viewContext)
        statusOne.alliance = alliance

        let modelTwo = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let statusTwo = EventStatusPlayoff.insert(modelTwo, eventKey: event.key!, teamKey: "frc1", in: viewContext)

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
        let event = coreDataTestFixture.insertDistrictEvent()

        let model = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let status = EventStatusPlayoff.insert(model, eventKey: event.key!, teamKey: "frc1", in: viewContext)

        let modelAlliance = TBAAlliance(name: nil, backup: nil, declines: nil, picks: ["frc1"], status: TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil))
        let alliance = EventAlliance.insert(modelAlliance, eventKey: event.key!, in: viewContext)
        alliance.status = status
        alliance.event = event

        XCTAssertNoThrow(try viewContext.save())

        // Should not delete when attached to an Alliance
        viewContext.delete(status)
        XCTAssertThrowsError(try viewContext.save())
        viewContext.rollback()
        alliance.status = nil

        XCTAssertNoThrow(try viewContext.save())

        let modelStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key!)
        let eventStatus = EventStatus.insert(modelStatus, in: viewContext)
        eventStatus.playoff = status
        eventStatus.event = event

        XCTAssertNoThrow(try viewContext.save())

        // Should not delete when attached to an EventStatus
        viewContext.delete(status)
        XCTAssertThrowsError(try viewContext.save())
        viewContext.rollback()
        eventStatus.playoff = nil

        // Should delete fine
        viewContext.delete(status)
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_allianceLevel() {
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: viewContext)
        // No level - should be nil
        XCTAssertNil(status.allianceLevel)

        // Not a final
        status.level = "sf"
        XCTAssertEqual(status.allianceLevel, "SF")

        // A final loss
        status.status = "lost"
        status.level = "f"
        XCTAssertEqual(status.allianceLevel, "F")

        // A final win
        status.status = "won"
        status.level = "f"
        XCTAssertEqual(status.allianceLevel, "W")
    }

}
