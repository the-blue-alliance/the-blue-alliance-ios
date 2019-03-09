import XCTest
@testable import TBA

class EventAllianceTestCase: CoreDataTestCase {

    func test_insert() {
        let event = insertDistrictEvent()

        let status = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let model = TBAAlliance(name: "Alliance 1", backup: nil, declines: ["frc5"], picks: ["frc1", "frc2", "frc3"], status: status)
        let alliance = EventAlliance.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)

        XCTAssertEqual(alliance.name, "Alliance 1")
        XCTAssertNil(alliance.backup)

        let pickKeys = (alliance.picks!.array as! [TeamKey]).map({ $0.key! })
        XCTAssertEqual(pickKeys, ["frc1", "frc2", "frc3"])

        let declineKeys = (alliance.declines!.array as! [TeamKey]).map({ $0.key! })
        XCTAssertEqual(declineKeys, ["frc5"])

        XCTAssertNotNil(alliance.status)

        // Save should fail - Alliance must have an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.addToAlliances(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = insertDistrictEvent()

        let modelBackup = TBAAllianceBackup(teamIn: "frc6", teamOut: "frc2")
        let modelStatus = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let modelOne = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1", "frc2", "frc3"], status: modelStatus)
        let allianceOne = EventAlliance.insert(modelOne, eventKey: event.key!, in: persistentContainer.viewContext)

        let status = allianceOne.status!
        let backup = allianceOne.backup!

        event.addToAlliances(allianceOne)

        let modelTwo = TBAAlliance(name: "Alliance 2", backup: nil, declines: nil, picks: ["frc1", "frc2", "frc4"], status: nil)
        let allianceTwo = EventAlliance.insert(modelTwo, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToAlliances(allianceTwo)

        // Two different sets of picks - shouldn't be the same alliance
        XCTAssertNotEqual(allianceOne, allianceTwo)

        let modelThree = TBAAlliance(name: "Alliance 3", backup: nil, declines: nil, picks: ["frc1", "frc2", "frc3"], status: nil)
        let allianceThree = EventAlliance.insert(modelThree, eventKey: event.key!, in: persistentContainer.viewContext)

        XCTAssertEqual(allianceOne, allianceThree)

        XCTAssertEqual(allianceOne.name, "Alliance 3")

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Status should be deleted - it's an orphan
        XCTAssertNil(status.managedObjectContext)

        // Backup should be delete - it's an orphan
        XCTAssertNil(backup.managedObjectContext)
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let modelBackup = TBAAllianceBackup(teamIn: "frc2", teamOut: "frc3")
        let modelStatus = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)

        let model = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1"], status: modelStatus)
        let alliance = EventAlliance.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToAlliances(alliance)

        let teamKey = alliance.picks!.firstObject! as! TeamKey
        let status = alliance.status!
        let backup = alliance.backup!

        // Should delete just fine
        persistentContainer.viewContext.delete(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event managed it's relationship properly
        XCTAssertEqual(event.alliances?.count, 0)

        // Our TeamKey shouldn't be deleted
        XCTAssertNotNil(teamKey.managedObjectContext)

        // Our Playoff Status should be deleted
        XCTAssertNil(status.managedObjectContext)

        // Our EventAllianceBackup should be deleted - it isn't an orphan yet
        XCTAssertNil(backup.managedObjectContext)
    }

    func test_delete_backup() {
        let event = insertDistrictEvent()

        let modelBackup = TBAAllianceBackup(teamIn: "frc2", teamOut: "frc3")

        let modelOne = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1"], status: nil)
        let allianceOne = EventAlliance.insert(modelOne, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToAlliances(allianceOne)

        let backup = allianceOne.backup!

        // Attach our Backup to another alliance, so it's not an oprhan after AllianceOne is gone
        let eventTwo = insertDistrictEvent(eventKey: "2018mike2")
        let modelTwo = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1"], status: nil)
        let allianceTwo = EventAlliance.insert(modelTwo, eventKey: eventTwo.key!, in: persistentContainer.viewContext)
        eventTwo.addToAlliances(allianceTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Sanity check
        XCTAssertEqual(allianceTwo.backup, backup)

        // Should delete just fine
        persistentContainer.viewContext.delete(allianceOne)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our EventAllianceBackup shouldn't be deleted - it isn't an orphan yet
        XCTAssertNotNil(backup.managedObjectContext)
        XCTAssert(backup.alliances!.onlyObject(allianceTwo))

        // Delete our second alliance - this will drop our backup's last relationship
        persistentContainer.viewContext.delete(allianceTwo)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our EventAllianceBackup should be deleted (backup.allianceStatus ?)
        XCTAssertNil(backup.managedObjectContext)
    }

    func test_delete_backup_status() {
        let event = insertDistrictEvent()

        let modelBackup = TBAAllianceBackup(teamIn: "frc2", teamOut: "frc3")

        let model = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1"], status: nil)
        let alliance = EventAlliance.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToAlliances(alliance)

        let backup = alliance.backup!

        // Attach the Backup to an AllianceStatus
        let allianceStatusModel = TBAEventStatusAlliance(number: 4, pick: 0, name: "Alliance 4", backup: modelBackup)
        let allianceStatus = EventStatusAlliance.insert(allianceStatusModel, eventKey: event.key!, teamKey: "frc1", in: persistentContainer.viewContext)
        let modelEventStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key!)
        let eventStatus = EventStatus.insert(modelEventStatus, in: persistentContainer.viewContext)
        eventStatus.alliance = allianceStatus
        eventStatus.event = event

        // Sanity check
        XCTAssertEqual(allianceStatus.backup, backup)

        // Should delete just fine
        persistentContainer.viewContext.delete(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our EventAllianceBackup shouldn't be deleted - it isn't an orphan yet
        XCTAssertNotNil(backup.managedObjectContext)
        XCTAssertNotNil(allianceStatus.backup)
    }

    func test_delete_status() {
        // Should not delete status when still attached to an Event Status
        let event = insertDistrictEvent()

        let modelStatus = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)

        let model = TBAAlliance(name: "Alliance 1", backup: nil, declines: nil, picks: ["frc1"], status: modelStatus)
        let alliance = EventAlliance.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToAlliances(alliance)

        let status = alliance.status!

        // Attach our Status to an Event Status
        let modelEventStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key!)
        let eventStatus = EventStatus.insert(modelEventStatus, in: persistentContainer.viewContext)
        eventStatus.playoff = status
        eventStatus.event = event

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Should delete just fine
        persistentContainer.viewContext.delete(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our EventStatus shouldn't be deleted - it isn't an orphan yet
        XCTAssertNotNil(status.managedObjectContext)
        XCTAssertEqual(eventStatus.playoff, status)
        XCTAssertNil(status.alliance)
    }

    func test_isOrphaned() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        // No Event - should be orphaned
        XCTAssert(alliance.isOrphaned)

        let event = Event.init(entity: Event.entity(), insertInto: persistentContainer.viewContext)
        event.addToAlliances(alliance)
        // Attached to an Event - should not be orphaned
        XCTAssertFalse(alliance.isOrphaned)

        event.removeFromAlliances(alliance)
        // Not attached to an Event - should be orphaned
        XCTAssert(alliance.isOrphaned)
    }

}
