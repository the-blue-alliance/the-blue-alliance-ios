import TBAKit
import XCTest
@testable import The_Blue_Alliance

class EventAllianceTestCase: CoreDataTestCase {

    func test_insert() {
        let event = districtEvent()

        let model = TBAAlliance(name: "Alliance 1", backup: nil, declines: ["frc5"], picks: ["frc1", "frc2", "frc3"], status: nil)
        let alliance = EventAlliance.insert(model, eventKey: event.key!, in: persistentContainer.viewContext)

        XCTAssertEqual(alliance.name, "Alliance 1")
        XCTAssertNil(alliance.backup)

        let pickKeys = (alliance.picks!.array as! [TeamKey]).map({ $0.key! })
        XCTAssertEqual(pickKeys, ["frc1", "frc2", "frc3"])

        let declineKeys = (alliance.declines!.array as! [TeamKey]).map({ $0.key! })
        XCTAssertEqual(declineKeys, ["frc5"])

        XCTAssertNil(alliance.status)

        // Save should fail - Alliance must have an Event
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        event.addToAlliances(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let event = districtEvent()

        let modelBackup = TBAAllianceBackup(teamIn: "frc6", teamOut: "frc2")
        let modelOne = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1", "frc2", "frc3"], status: nil)
        let allianceOne = EventAlliance.insert(modelOne, eventKey: event.key!, in: persistentContainer.viewContext)
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

        // Backup should be delete - it's an orphan
        XCTAssertNil(backup.managedObjectContext)
    }

    func test_delete() {
        let event = districtEvent()

        let modelBackup = TBAAllianceBackup(teamIn: "frc2", teamOut: "frc3")

        let modelOne = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1"], status: nil)
        let allianceOne = EventAlliance.insert(modelOne, eventKey: event.key!, in: persistentContainer.viewContext)
        event.addToAlliances(allianceOne)

        // TODO: Update to support EventStatusPlayoff

        let teamKey = allianceOne.picks!.firstObject! as! TeamKey
        let backup = allianceOne.backup!

        let eventTwo = districtEvent(eventKey: "2018mike2")
        let modelTwo = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: nil, picks: ["frc1"], status: nil)
        let allianceTwo = EventAlliance.insert(modelTwo, eventKey: eventTwo.key!, in: persistentContainer.viewContext)
        eventTwo.addToAlliances(allianceTwo)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Should delete just fine
        persistentContainer.viewContext.delete(allianceOne)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event managed it's relationship properly
        XCTAssertEqual(event.alliances?.count, 0)

        // Our TeamKey shouldn't be deleted
        XCTAssertNotNil(teamKey.managedObjectContext)

        // Our EventAllianceBackup shouldn't be deleted - it isn't an orphan yet
        XCTAssertNotNil(backup.managedObjectContext)

        persistentContainer.viewContext.delete(allianceTwo)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Event managed it's relationship properly
        XCTAssertEqual(eventTwo.alliances?.count, 0)

        // Our TeamKey shouldn't be deleted
        XCTAssertNotNil(teamKey.managedObjectContext)

        // Our EventAllianceBackup should be deleted
        XCTAssertNil(backup.managedObjectContext)
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
