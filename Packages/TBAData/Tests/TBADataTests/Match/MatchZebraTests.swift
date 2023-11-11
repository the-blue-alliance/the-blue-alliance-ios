import CoreData
import TBAKit
import XCTest
@testable import TBAData

class MatchZebraTestCase: TBADataTestCase {

    func test_key() {
        let zebra = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        zebra.keyRaw = "2020miket_qm1"
        XCTAssertEqual(zebra.key, "2020miket_qm1")
    }

    func test_times() {
        let zebra = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        zebra.timesRaw = [0.1, 0.2, 0.3]
        XCTAssertEqual(zebra.times, [0.1, 0.2, 0.3])
    }

    func test_match() {
        let zebra = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        zebra.matchRaw = match
        XCTAssertEqual(zebra.match, match)
    }

    func test_alliances() {
        let zebra = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        zebra.alliancesRaw = NSSet(array: [])
        XCTAssertEqual(zebra.alliances, [])
        let alliance = MatchZebraAlliance.init(entity: MatchZebraAlliance.entity(), insertInto: persistentContainer.viewContext)
        zebra.alliancesRaw = NSSet(array: [alliance])
        XCTAssertEqual(zebra.alliances, [alliance])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<MatchZebra> = MatchZebra.fetchRequest()
        XCTAssertEqual(fr.entityName, MatchZebra.entityName)
    }

    func test_insert() {
        let modelMatch = TBAMatch(key: "2020miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2020miket")
        let modelZebra = TBAMatchZebra(key: modelMatch.key, times: [0.0, 0.1], alliances: [
            "red": [
                TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
            ],
            "blue": [
                TBAMachZebraTeam(teamKey: "frc2", xs: [0.3, 0.1], ys: [0.2, 1.5])
            ]
        ])
        let zebra = MatchZebra.insert(modelZebra, in: persistentContainer.viewContext)

        XCTAssertEqual(zebra.key, "2020miket_f1m1")
        XCTAssertEqual(zebra.times, [0.0, 0.1])
        XCTAssertEqual(zebra.alliances.count, 2)

        // Should throw - needs to be attached to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        zebra.matchRaw = Match.insert(modelMatch, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let key = "key"
        let modelZebra = TBAMatchZebra(key: key, times: [0.0, 0.1], alliances: [
            "red": [
                TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
            ],
            "blue": [
                TBAMachZebraTeam(teamKey: "frc2", xs: [0.3, 0.1], ys: [0.2, 1.5])
            ]
        ])
        let zebra = MatchZebra.insert(modelZebra, in: persistentContainer.viewContext)

        XCTAssertEqual(zebra.key, key)
        XCTAssertEqual(zebra.times, [0.0, 0.1])
        XCTAssertEqual(zebra.alliances.count, 2)

        let redAlliance = zebra.alliances.first(where: { $0.allianceKey == "red" })!
        let blueAlliance = zebra.alliances.first(where: { $0.allianceKey == "blue" })!

        let modelZebraNew = TBAMatchZebra(key: key, times: [0.0, 0.1, 0.2], alliances: [
            "red": [
                TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1, 1.1], ys: [0.2, nil, 2.2])
            ]
        ])
        let zebraNew = MatchZebra.insert(modelZebraNew, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(zebra, zebraNew)

        // Make sure our new setup looks right
        XCTAssertEqual(zebra.key, key)
        XCTAssertEqual(zebra.times, [0.0, 0.1, 0.2])
        XCTAssertEqual(zebra.alliances.count, 1)

        // Make sure our Red alliance still exists and our Blue alliance is deleed
        XCTAssert(blueAlliance.isDeleted)
        XCTAssertFalse(redAlliance.isDeleted)

        let modelZebraDifferent = TBAMatchZebra(key: "new_key", times: [0.0, 0.1, 0.2], alliances: [
            "red": [
                TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1, 1.1], ys: [0.2, nil, 2.2])
            ]
        ])
        let zebraDifferent = MatchZebra.insert(modelZebraDifferent, in: persistentContainer.viewContext)

        // Check that changing the key inserts, not updates
        XCTAssertNotEqual(zebra, zebraDifferent)
    }

    func test_delete() {
        let modelMatch = TBAMatch(key: "2020miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2020miket")
        let modelZebra = TBAMatchZebra(key: modelMatch.key, times: [0.0, 0.1], alliances: [
            "red": [
                TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
            ],
            "blue": [
                TBAMachZebraTeam(teamKey: "frc2", xs: [0.3, 0.1], ys: [0.2, 1.5])
            ]
        ])
        let zebra = MatchZebra.insert(modelZebra, in: persistentContainer.viewContext)
        let match = Match.insert(modelMatch, in: persistentContainer.viewContext)
        zebra.matchRaw = match

        let alliances = zebra.alliances

        persistentContainer.viewContext.delete(zebra)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure Zebra data was deleted
        XCTAssertNil(zebra.managedObjectContext)

        // Ensure our Match wasn't deleted
        XCTAssertNotNil(match.managedObjectContext)

        // Ensure our Zebra Alliances were deleted
        XCTAssert(alliances.reduce(true) {
            return $0 && ($1.managedObjectContext == nil)
        })
    }

    func test_isOrphaned() {
        let zebra = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(zebra.isOrphaned)

        zebra.matchRaw = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(zebra.isOrphaned)

        zebra.matchRaw = nil
        XCTAssert(zebra.isOrphaned)
    }

}
