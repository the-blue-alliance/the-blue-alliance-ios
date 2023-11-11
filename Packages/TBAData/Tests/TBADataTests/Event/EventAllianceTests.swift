import CoreData
import TBAKit
import XCTest
@testable import TBAData

class EventAllianceTestCase: TBADataTestCase {

    func test_name() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(alliance.name)
        alliance.nameRaw = "red"
        XCTAssertEqual(alliance.name, "red")
    }

    func test_backup() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(alliance.backup)
        let backup = EventAllianceBackup.init(entity: EventAllianceBackup.entity(), insertInto: persistentContainer.viewContext)
        alliance.backupRaw = backup
        XCTAssertEqual(alliance.backup, backup)
    }

    func test_declines() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(alliance.declines.count, 0)
        let team = insertTeam()
        alliance.declinesRaw = NSOrderedSet(array: [team])
        XCTAssertEqual(alliance.declines.array as! [Team], [team])
    }

    func test_event() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        let event = insertEvent()
        alliance.eventRaw = event
        XCTAssertEqual(alliance.event, event)
    }

    func test_picks() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(alliance.picks.count, 0)
        let team = insertTeam()
        alliance.picksRaw = NSOrderedSet(array: [team])
        XCTAssertEqual(alliance.picks.array as! [Team], [team])
    }

    func test_status() {
        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        alliance.statusRaw = status
        XCTAssertEqual(alliance.status, status)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<EventAlliance> = EventAlliance.fetchRequest()
        XCTAssertEqual(fr.entityName, EventAlliance.entityName)
    }

    func test_insert() {
        let event = insertDistrictEvent()

        let status = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let model = TBAAlliance(name: "Alliance 1", backup: nil, declines: ["frc5"], picks: ["frc1", "frc2", "frc3"], status: status)
        let alliance = EventAlliance.insert(model, eventKey: event.key, in: persistentContainer.viewContext)

        XCTAssertEqual(alliance.name, "Alliance 1")
        XCTAssertNil(alliance.backup)

        let pickKeys = (alliance.picks.array as! [Team]).map({ $0.key })
        XCTAssertEqual(pickKeys, ["frc1", "frc2", "frc3"])

        let declineKeys = (alliance.declines.array as! [Team]).map({ $0.key })
        XCTAssertEqual(declineKeys, ["frc5"])

        XCTAssertNotNil(alliance.status)

        // Save should fail - Alliance must have an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.addToAlliancesRaw(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_noPicks() {
        let event = insertDistrictEvent()

        let status = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let model = TBAAlliance(name: "Alliance 1", backup: nil, declines: [], picks: [], status: status)
        let alliance = EventAlliance.insert(model, eventKey: event.key, in: persistentContainer.viewContext)
        alliance.eventRaw = event
        XCTAssertNil(alliance.status)

        // Call insert again with a status, make sure status gets deleted
        let s = EventStatusPlayoff.insert(status, eventKey: event.key, teamKey: "frc7332", in: persistentContainer.viewContext)
        alliance.statusRaw = s

        // Sanity check
        XCTAssertNotNil(alliance.status)

        let newAlliance = EventAlliance.insert(model, eventKey: event.key, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(alliance, newAlliance)
        XCTAssertNil(alliance.status)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our status object should be deleted
        XCTAssertNil(s.managedObjectContext)
    }

    func test_update() {
        let event = insertDistrictEvent()

        let modelBackup = TBAAllianceBackup(teamIn: "frc6", teamOut: "frc2")
        let modelStatus = TBAAllianceStatus(currentRecord: nil, level: nil, playoffAverage: nil, record: nil, status: nil)
        let modelOne = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1", "frc2", "frc3"], status: modelStatus)
        let allianceOne = EventAlliance.insert(modelOne, eventKey: event.key, in: persistentContainer.viewContext)

        let status = allianceOne.status!
        let backup = allianceOne.backup!

        event.addToAlliancesRaw(allianceOne)

        let modelTwo = TBAAlliance(name: "Alliance 2", backup: nil, declines: nil, picks: ["frc1", "frc2", "frc4"], status: nil)
        let allianceTwo = EventAlliance.insert(modelTwo, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToAlliancesRaw(allianceTwo)

        // Two different sets of picks - shouldn't be the same alliance
        XCTAssertNotEqual(allianceOne, allianceTwo)

        let modelThree = TBAAlliance(name: "Alliance 3", backup: nil, declines: nil, picks: ["frc1", "frc2", "frc3"], status: nil)
        let allianceThree = EventAlliance.insert(modelThree, eventKey: event.key, in: persistentContainer.viewContext)

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
        let alliance = EventAlliance.insert(model, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToAlliancesRaw(alliance)

        let teamKey = alliance.picks.firstObject! as! Team
        let status = alliance.status!
        let backup = alliance.backup!

        // Should delete just fine
        persistentContainer.viewContext.delete(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event managed it's relationship properly
        XCTAssertEqual(event.alliances.count, 0)

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
        let allianceOne = EventAlliance.insert(modelOne, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToAlliancesRaw(allianceOne)

        let backup = allianceOne.backup!

        // Attach our Backup to another alliance, so it's not an oprhan after AllianceOne is gone
        let eventTwo = insertDistrictEvent(eventKey: "2018mike2")
        let modelTwo = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1"], status: nil)
        let allianceTwo = EventAlliance.insert(modelTwo, eventKey: eventTwo.key, in: persistentContainer.viewContext)
        eventTwo.addToAlliancesRaw(allianceTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Sanity check
        XCTAssertEqual(allianceTwo.backup, backup)

        // Should delete just fine
        persistentContainer.viewContext.delete(allianceOne)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Our EventAllianceBackup shouldn't be deleted - it isn't an orphan yet
        XCTAssertNotNil(backup.managedObjectContext)
        XCTAssert(backup.alliances.onlyObject(allianceTwo))

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
        let alliance = EventAlliance.insert(model, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToAlliancesRaw(alliance)

        let backup = alliance.backup!

        // Attach the Backup to an AllianceStatus
        let allianceStatusModel = TBAEventStatusAlliance(number: 4, pick: 0, name: "Alliance 4", backup: modelBackup)
        let allianceStatus = EventStatusAlliance.insert(allianceStatusModel, eventKey: event.key, teamKey: "frc1", in: persistentContainer.viewContext)
        let modelEventStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key)
        let eventStatus = EventStatus.insert(modelEventStatus, in: persistentContainer.viewContext)
        eventStatus.allianceRaw = allianceStatus
        eventStatus.eventRaw = event

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
        let alliance = EventAlliance.insert(model, eventKey: event.key, in: persistentContainer.viewContext)
        event.addToAlliancesRaw(alliance)

        let status = alliance.status!

        // Attach our Status to an Event Status
        let modelEventStatus = TBAEventStatus(teamKey: "frc1", eventKey: event.key)
        let eventStatus = EventStatus.insert(modelEventStatus, in: persistentContainer.viewContext)
        eventStatus.playoffRaw = status
        eventStatus.eventRaw = event

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
        event.addToAlliancesRaw(alliance)
        // Attached to an Event - should not be orphaned
        XCTAssertFalse(alliance.isOrphaned)

        event.removeFromAlliancesRaw(alliance)
        // Not attached to an Event - should be orphaned
        XCTAssert(alliance.isOrphaned)
    }

}
