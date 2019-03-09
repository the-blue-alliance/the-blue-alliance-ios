import XCTest
@testable import TBA

class EventTeamStatTestCase: CoreDataTestCase {

    func test_insert() {
        let event = insertDistrictEvent()

        let model = TBAStat(teamKey: "frc1", ccwm: 2.2, dpr: 3.3, opr: 4.44)
        let stat = EventTeamStat.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)

        XCTAssertEqual(stat.teamKey?.key, "frc1")
        XCTAssertEqual(stat.opr, 4.44)
        XCTAssertEqual(stat.dpr, 3.3)
        XCTAssertEqual(stat.ccwm, 2.2)

        // Should fail - stat must be attached to an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        stat.event = event
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let modelOne = TBAStat(teamKey: "frc1", ccwm: 2.2, dpr: 3.3, opr: 4.44)
        let statOne = EventTeamStat.insert(modelOne, eventKey: event.key!, in: persistentContainer.viewContext)
        statOne.event = event

        let modelTwo = TBAStat(teamKey: "frc1", ccwm: 3.3, dpr: 4.4, opr: 5.5)
        let statTwo = EventTeamStat.insert(modelTwo, eventKey: event.key!, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(statOne, statTwo)

        XCTAssertEqual(statOne.ccwm, 3.3)
        XCTAssertEqual(statOne.dpr, 4.4)
        XCTAssertEqual(statOne.opr, 5.5)
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let model = TBAStat(teamKey: "frc1", ccwm: 2.2, dpr: 3.3, opr: 4.44)
        let stat = EventTeamStat.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)
        stat.event = event

        let teamKey = stat.teamKey!

        persistentContainer.viewContext.delete(stat)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Event and TeamKey should both not be deleted
        XCTAssertNotNil(event.managedObjectContext)
        XCTAssertNotNil(teamKey.managedObjectContext)
    }

    func test_isOrphaned() {
        let stat = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(stat.isOrphaned)

        stat.event = insertDistrictEvent()
        XCTAssertFalse(stat.isOrphaned)
        stat.event = nil

        XCTAssert(stat.isOrphaned)
    }

}
