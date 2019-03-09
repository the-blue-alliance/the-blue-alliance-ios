import XCTest
@testable import TBA

class EventAllianceBackupTestCase: CoreDataTestCase {

    func test_insert() {
        let modelBackup = TBAAllianceBackup(teamIn: "frc1", teamOut: "frc2")
        let backup = EventAllianceBackup.insert(modelBackup, in: persistentContainer.viewContext)

        XCTAssertEqual(backup.inTeam?.key, "frc1")
        XCTAssertEqual(backup.outTeam?.key, "frc2")

        // Should be able to be saved without an alliance or a status
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let modelBackupOne = TBAAllianceBackup(teamIn: "frc1", teamOut: "frc2")
        let backupOne = EventAllianceBackup.insert(modelBackupOne, in: persistentContainer.viewContext)

        let modelBackupTwo = TBAAllianceBackup(teamIn: "frc1", teamOut: "frc2")
        let backupTwo = EventAllianceBackup.insert(modelBackupTwo, in: persistentContainer.viewContext)

        XCTAssertEqual(backupOne, backupTwo)
    }

    func test_delete() {
        let event = insertDistrictEvent()

        let modelBackup = TBAAllianceBackup(teamIn: "frc1", teamOut: "frc2")
        let modelAlliance = TBAAlliance(name: "Alliance 1", backup: modelBackup, declines: ["frc5"], picks: ["frc1", "frc2", "frc3"], status: nil)
        let alliance = EventAlliance.insert(modelAlliance, eventKey: event.key!, in: persistentContainer.viewContext)
        let backup = alliance.backup!

        event.addToAlliances(alliance)

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Backup cannot be saved while still attached to an EventAlliance
        persistentContainer.viewContext.delete(backup)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        alliance.backup = nil
        persistentContainer.viewContext.delete(backup)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_isOrphaned() {
        let backup = EventAllianceBackup.init(entity: EventAllianceBackup.entity(), insertInto: persistentContainer.viewContext)

        // No values - should be marked as orphaned
        XCTAssert(backup.isOrphaned)

        // Has alliances, but no status - not orphaned
        let eventAlliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        backup.addToAlliances(eventAlliance)
        XCTAssertFalse(backup.isOrphaned)

        backup.alliances = nil

        // Has a status, but no allianes - not orphaned
        let status = EventStatusAlliance.init(entity: EventStatusAlliance.entity(), insertInto: persistentContainer.viewContext)
        backup.allianceStatus = status
        XCTAssertFalse(backup.isOrphaned)

        // No status, empty alliances - should be marked as orphaned
        backup.alliances = NSSet(array: [])
        backup.allianceStatus = nil
        XCTAssert(backup.isOrphaned)
    }

}
