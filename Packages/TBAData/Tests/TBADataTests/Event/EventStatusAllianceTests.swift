import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventStatusAllianceTestCase: TBADataTestCase {

    func test_name() {
        let status = EventStatusAlliance.init(entity: EventStatusAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.name)
        status.nameRaw = "qual"
        XCTAssertEqual(status.name, "qual")
    }

    func test_number() {
        let status = EventStatusAlliance.init(entity: EventStatusAlliance.entity(), insertInto: persistentContainer.viewContext)
        status.numberRaw = NSNumber(value: 2)
        XCTAssertEqual(status.number, 2)
    }

    func test_pick() {
        let status = EventStatusAlliance.init(entity: EventStatusAlliance.entity(), insertInto: persistentContainer.viewContext)
        status.pickRaw = NSNumber(value: 2)
        XCTAssertEqual(status.pick, 2)
    }

    func test_backup() {
        let status = EventStatusAlliance.init(entity: EventStatusAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(status.backup)
        let backup = EventAllianceBackup.init(entity: EventAllianceBackup.entity(), insertInto: persistentContainer.viewContext)
        status.backupRaw = backup
        XCTAssertEqual(status.backup, backup)
    }

    func test_eventStatus() {
        let status = EventStatusAlliance.init(entity: EventStatusAlliance.entity(), insertInto: persistentContainer.viewContext)
        let eventStatus = EventStatus.init(entity: EventStatus.entity(), insertInto: persistentContainer.viewContext)
        status.eventStatusRaw = eventStatus
        XCTAssertEqual(status.eventStatus, eventStatus)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventStatusAlliance> = EventStatusAlliance.fetchRequest()
        XCTAssertEqual(fr.entityName, EventStatusAlliance.entityName)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let backupModel = TBAAllianceBackup(teamIn: "frc3", teamOut: "frc2")
        let model = TBAEventStatusAlliance(number: 2, pick: 1, name: "Alliance One", backup: backupModel)
        let allianceStatus = EventStatusAlliance.insert(model, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        XCTAssertEqual(allianceStatus.name, "Alliance One")
        XCTAssertEqual(allianceStatus.number, 2)
        XCTAssertEqual(allianceStatus.pick, 1)
        XCTAssertNotNil(allianceStatus.backup)

        // Should fail - needs an EventStatus
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let modelEventStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key)
        let eventStatus = EventStatus.insert(modelEventStatus, in: persistentContainer.viewContext)
        eventStatus.eventRaw = event
        eventStatus.allianceRaw = allianceStatus

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let backupModel = TBAAllianceBackup(teamIn: "frc3", teamOut: "frc2")
        let modelOne = TBAEventStatusAlliance(number: 2, pick: 1, name: "Alliance One", backup: backupModel)
        let allianceStatusOne = EventStatusAlliance.insert(modelOne, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        let backup = allianceStatusOne.backup!

        let modelEventStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key)
        let eventStatus = EventStatus.insert(modelEventStatus, in: persistentContainer.viewContext)
        eventStatus.eventRaw = event
        eventStatus.allianceRaw = allianceStatusOne

        let modelTwo = TBAEventStatusAlliance(number: 3, pick: 2)
        let allianceStatusTwo = EventStatusAlliance.insert(modelTwo, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(allianceStatusOne, allianceStatusTwo)

        // Make sure our values got updated properly
        XCTAssertEqual(allianceStatusOne.pick, 2)
        XCTAssertEqual(allianceStatusOne.number, 3)
        XCTAssertNil(allianceStatusOne.name)
        XCTAssertNil(allianceStatusOne.backup)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our Backup should be deleted
        XCTAssertNil(backup.managedObjectContext)
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let backupModel = TBAAllianceBackup(teamIn: "frc3", teamOut: "frc2")
        let model = TBAEventStatusAlliance(number: 2, pick: 1, name: "Alliance One", backup: backupModel)
        let allianceStatus = EventStatusAlliance.insert(model, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        let backup = allianceStatus.backup!

        persistentContainer.viewContext.delete(allianceStatus)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Backup should be deleted as well
        XCTAssertNil(backup.managedObjectContext)
    }

    func test_delete_backup() {
        let event = insertDistrictEvent()

        let backupModel = TBAAllianceBackup(teamIn: "frc3", teamOut: "frc2")
        let model = TBAEventStatusAlliance(number: 2, pick: 1, name: "Alliance One", backup: backupModel)
        let allianceStatus = EventStatusAlliance.insert(model, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)

        let backup = allianceStatus.backup!

        let allianceModel = TBAAlliance(name: nil, backup: backupModel, declines: nil, picks: ["frc1"], status: nil)
        let alliance = EventAlliance.insert(allianceModel, eventKey: event.key, in: persistentContainer.viewContext)
        alliance.eventRaw = event

        // Sanity check
        XCTAssertEqual(alliance.backup, backup)

        persistentContainer.viewContext.delete(allianceStatus)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Backup should not be deleted
        XCTAssertNotNil(backup.managedObjectContext)
    }

}
