import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventTeamStatTestCase: TBADataTestCase {

    func test_opr() {
        let stat = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        stat.oprRaw = NSNumber(value: 20.2)
        XCTAssertEqual(stat.opr, 20.2)
    }

    func test_dpr() {
        let stat = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        stat.dprRaw = NSNumber(value: 20.2)
        XCTAssertEqual(stat.dpr, 20.2)
    }

    func test_ccwm() {
        let stat = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        stat.ccwmRaw = NSNumber(value: 20.2)
        XCTAssertEqual(stat.ccwm, 20.2)
    }

    func test_event() {
        let stat = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        let event = insertEvent()
        stat.eventRaw = event
        XCTAssertEqual(stat.event, event)
    }

    func test_team() {
        let stat = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        let team = insertTeam()
        stat.teamRaw = team
        XCTAssertEqual(stat.team, team)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventTeamStat> = EventTeamStat.fetchRequest()
        XCTAssertEqual(fr.entityName, EventTeamStat.entityName)
    }

    func test_oprKeyPath() {
        let kp = EventTeamStat.oprKeyPath()
        XCTAssertEqual(kp, #keyPath(EventTeamStat.oprRaw))
    }

    func test_dprKeyPath() {
        let kp = EventTeamStat.dprKeyPath()
        XCTAssertEqual(kp, #keyPath(EventTeamStat.dprRaw))
    }

    func test_ccwmKeyPath() {
        let kp = EventTeamStat.ccwmKeyPath()
        XCTAssertEqual(kp, #keyPath(EventTeamStat.ccwmRaw))
    }

    func test_oprSortDescriptor() {
        let sd = EventTeamStat.oprSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(EventTeamStat.oprRaw))
        XCTAssertFalse(sd.ascending)
    }

    func test_dprSortDescriptor() {
        let sd = EventTeamStat.dprSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(EventTeamStat.dprRaw))
        XCTAssertFalse(sd.ascending)
    }

    func test_ccwmSortDescriptor() {
        let sd = EventTeamStat.ccwmSortDescriptor()
        XCTAssertEqual(sd.key, #keyPath(EventTeamStat.ccwmRaw))
        XCTAssertFalse(sd.ascending)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let model = TBAStat(teamKey: "frc1", ccwm: 2.2, dpr: 3.3, opr: 4.44)
        let stat = EventTeamStat.insert(model, eventKey: event.key, in: persistentContainer.viewContext)

        XCTAssertEqual(stat.team.key, "frc1")
        XCTAssertEqual(stat.opr, 4.44)
        XCTAssertEqual(stat.dpr, 3.3)
        XCTAssertEqual(stat.ccwm, 2.2)

        // Should fail - stat must be attached to an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        stat.eventRaw = event
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let modelOne = TBAStat(teamKey: "frc1", ccwm: 2.2, dpr: 3.3, opr: 4.44)
        let statOne = EventTeamStat.insert(modelOne, eventKey: event.key, in: persistentContainer.viewContext)
        statOne.eventRaw = event

        let modelTwo = TBAStat(teamKey: "frc1", ccwm: 3.3, dpr: 4.4, opr: 5.5)
        let statTwo = EventTeamStat.insert(modelTwo, eventKey: event.key, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(statOne, statTwo)

        XCTAssertEqual(statOne.ccwm, 3.3)
        XCTAssertEqual(statOne.dpr, 4.4)
        XCTAssertEqual(statOne.opr, 5.5)
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let model = TBAStat(teamKey: "frc1", ccwm: 2.2, dpr: 3.3, opr: 4.44)
        let stat = EventTeamStat.insert(model, eventKey: event.key, in: persistentContainer.viewContext)
        stat.eventRaw = event

        let team = stat.team

        persistentContainer.viewContext.delete(stat)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Event and TeamKey should both not be deleted
        XCTAssertNotNil(event.managedObjectContext)
        XCTAssertNotNil(team.managedObjectContext)
    }

    func test_isOrphaned() {
        let stat = EventTeamStat.init(entity: EventTeamStat.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(stat.isOrphaned)

        stat.eventRaw = insertDistrictEvent()
        XCTAssertFalse(stat.isOrphaned)
        stat.eventRaw = nil

        XCTAssert(stat.isOrphaned)
    }

}
