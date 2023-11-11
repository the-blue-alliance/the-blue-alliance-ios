import CoreData
import TBAKit
import XCTest
@testable import TBAData

class MatchZebraAllianceTestCase: TBADataTestCase {

    func test_allianceKey() {
        let alliance = MatchZebraAlliance.init(entity: MatchZebraAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.allianceKeyRaw = "red"
        XCTAssertEqual(alliance.allianceKey, "red")
    }

    func test_zebra() {
        let alliance = MatchZebraAlliance.init(entity: MatchZebraAlliance.entity(), insertInto: persistentContainer.viewContext)
        let zebra = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        alliance.zebraRaw = zebra
        XCTAssertEqual(alliance.zebra, zebra)
    }

    func test_teams() {
        let alliance = MatchZebraAlliance.init(entity: MatchZebraAlliance.entity(), insertInto: persistentContainer.viewContext)
        let team = MatchZebraTeam.init(entity: MatchZebraTeam.entity(), insertInto: persistentContainer.viewContext)
        alliance.teamsRaw = NSSet(array: [team])
        XCTAssertEqual(alliance.teams, [team])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<MatchZebraAlliance> = MatchZebraAlliance.fetchRequest()
        XCTAssertEqual(fr.entityName, MatchZebraAlliance.entityName)
    }

    func test_insert() {
        let allianceKey = "red"
        let modelMatch = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")

        let team = TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
        let alliance = MatchZebraAlliance.insert(modelMatch.key, allianceKey: allianceKey, teams: [team], in: persistentContainer.viewContext)

        XCTAssertEqual(alliance.allianceKey, allianceKey)
        XCTAssertEqual(alliance.teams.count, 1)

        // Should throw - needs to be attached to a Match Zebra
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let modelZebra = TBAMatchZebra(key: modelMatch.key, times: [0.0, 0.1], alliances: [
            allianceKey: [team]
        ])
        let zebra = MatchZebra.insert(modelZebra, in: persistentContainer.viewContext)
        zebra.matchRaw = Match.insert(modelMatch, in: persistentContainer.viewContext)
        alliance.zebraRaw = zebra

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let key = "key"
        let allianceKey = "red"

        let alliance = MatchZebraAlliance.insert(key, allianceKey: allianceKey, teams: [TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])], in: persistentContainer.viewContext)

        // Zebra Alliance needs to be connected to Zebra data in order to filter properly
        let zebra = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        zebra.keyRaw = key
        alliance.zebraRaw = zebra

        let team = alliance.teams.first!

        XCTAssertEqual(alliance.allianceKey, allianceKey)
        XCTAssertEqual(alliance.teams.count, 1)

        let newAlliance = MatchZebraAlliance.insert(key, allianceKey: allianceKey, teams: [TBAMachZebraTeam(teamKey: "frc2", xs: [nil, 0.1], ys: [0.2, nil])], in: persistentContainer.viewContext)
        let newTeam = newAlliance.teams.first!

        // Sanity check
        XCTAssertEqual(alliance, newAlliance)

        XCTAssertEqual(alliance.allianceKey, allianceKey)
        XCTAssert(alliance.teams.contains(newTeam))
        XCTAssertFalse(alliance.teams.contains(team))

        // Make sure our Team was deleted
        XCTAssert(team.isDeleted)
        XCTAssertFalse(newTeam.isDeleted)
        XCTAssertNotEqual(team, newTeam)
    }

    func test_delete() {
        let team = TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
        let modelZebra = TBAMatchZebra(key: "key", times: [0.0, 0.1], alliances: [
            "red": [team]
        ])
        let zebra = MatchZebra.insert(modelZebra, in: persistentContainer.viewContext)
        zebra.matchRaw = insertMatch()
        let alliance = zebra.alliances.first!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let teams = alliance.teams

        persistentContainer.viewContext.delete(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure Zebra Alliance data was deleted
        XCTAssertNil(alliance.managedObjectContext)

        // Ensure Zebra wasn't deleted
        XCTAssertNotNil(zebra.managedObjectContext)

        // Ensure Match wasn't deleted
        XCTAssertNotNil(zebra.match.managedObjectContext)

        // Ensure our Zebra Teams were deleted
        XCTAssert(teams.reduce(true) {
            return $0 && ($1.managedObjectContext == nil)
        })
    }

    func test_isOrphaned() {
        let alliance = MatchZebraAlliance.init(entity: MatchZebraAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(alliance.isOrphaned)

        alliance.zebraRaw = MatchZebra.init(entity: MatchZebra.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(alliance.isOrphaned)

        alliance.zebraRaw = nil
        XCTAssert(alliance.isOrphaned)
    }

}
