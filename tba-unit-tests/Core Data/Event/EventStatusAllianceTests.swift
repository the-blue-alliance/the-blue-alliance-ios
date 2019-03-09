import XCTest
@testable import TBA

class EventStatusAllianceTestCase: CoreDataTestCase {

    func test_insert() {
        let event = insertDistrictEvent()

        let backupModel = TBAAllianceBackup(teamIn: "frc3", teamOut: "frc2")
        let model = TBAEventStatusAlliance(number: 2, pick: 1, name: "Alliance One", backup: backupModel)
        let allianceStatus = EventStatusAlliance.insert(model, eventKey: event.key!, teamKey: "frc1", in: persistentContainer.viewContext)

        XCTAssertEqual(allianceStatus.name, "Alliance One")
        XCTAssertEqual(allianceStatus.number, 2)
        XCTAssertEqual(allianceStatus.pick, 1)
        XCTAssertNotNil(allianceStatus.backup)

        // Should fail - needs an EventStatus
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let modelEventStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key!)
        let eventStatus = EventStatus.insert(modelEventStatus, in: persistentContainer.viewContext)
        eventStatus.event = event
        eventStatus.alliance = allianceStatus

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let backupModel = TBAAllianceBackup(teamIn: "frc3", teamOut: "frc2")
        let modelOne = TBAEventStatusAlliance(number: 2, pick: 1, name: "Alliance One", backup: backupModel)
        let allianceStatusOne = EventStatusAlliance.insert(modelOne, eventKey: event.key!, teamKey: "frc1", in: persistentContainer.viewContext)

        let backup = allianceStatusOne.backup!

        let modelEventStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key!)
        let eventStatus = EventStatus.insert(modelEventStatus, in: persistentContainer.viewContext)
        eventStatus.event = event
        eventStatus.alliance = allianceStatusOne

        let modelTwo = TBAEventStatusAlliance(number: 3, pick: 2)
        let allianceStatusTwo = EventStatusAlliance.insert(modelTwo, eventKey: event.key!, teamKey: "frc1", in: persistentContainer.viewContext)

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
        let allianceStatus = EventStatusAlliance.insert(model, eventKey: event.key!, teamKey: "frc1", in: persistentContainer.viewContext)

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
        let allianceStatus = EventStatusAlliance.insert(model, eventKey: event.key!, teamKey: "frc1", in: persistentContainer.viewContext)

        let backup = allianceStatus.backup!

        let allianceModel = TBAAlliance(name: nil, backup: backupModel, declines: nil, picks: ["frc1"], status: nil)
        let alliance = EventAlliance.insert(allianceModel, eventKey: event.key!, in: persistentContainer.viewContext)
        alliance.event = event

        // Sanity check
        XCTAssertEqual(alliance.backup, backup)

        persistentContainer.viewContext.delete(allianceStatus)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Backup should not be deleted
        XCTAssertNotNil(backup.managedObjectContext)
    }

}
