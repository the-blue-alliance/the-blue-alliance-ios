import CoreData
import TBAKit
import XCTest
@testable import TBAData

class MatchZebraTeamTestCase: TBADataTestCase {

    func test_xs() {
        let team = MatchZebraTeam.init(entity: MatchZebraTeam.entity(), insertInto: persistentContainer.viewContext)
        team.xsRaw = [NSNumber(value: 1.1), NSNull(), NSNumber(value: 2.1), NSNull(), NSNumber(value: 3.1), NSNull()]
        XCTAssertEqual(team.xs, [1.1, nil, 2.1, nil, 3.1, nil])
    }

    func test_xy() {
        let team = MatchZebraTeam.init(entity: MatchZebraTeam.entity(), insertInto: persistentContainer.viewContext)
        team.ysRaw = [NSNull(), NSNumber(value: 9.2), NSNumber(value: 7.1), NSNumber(value: 6.5), NSNull()]
        XCTAssertEqual(team.ys, [nil, 9.2, 7.1, 6.5, nil])
    }

    func test_alliance() {
        let team = MatchZebraTeam.init(entity: MatchZebraTeam.entity(), insertInto: persistentContainer.viewContext)
        let alliance = MatchZebraAlliance.init(entity: MatchZebraAlliance.entity(), insertInto: persistentContainer.viewContext)
        team.allianceRaw = alliance
        XCTAssertEqual(team.alliance, alliance)
    }

    func test_team() {
        let team = MatchZebraTeam.init(entity: MatchZebraTeam.entity(), insertInto: persistentContainer.viewContext)
        let t = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.teamRaw = t
        XCTAssertEqual(team.team, t)
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<MatchZebraTeam> = MatchZebraTeam.fetchRequest()
        XCTAssertEqual(fr.entityName, MatchZebraTeam.entityName)
    }

    func test_insert() {
        let key = "key"

        let teamModel = TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
        let team = MatchZebraTeam.insert(key, teamModel, in: persistentContainer.viewContext)

        XCTAssertEqual(team.team.key, "frc1")
        XCTAssertEqual(team.xs, [nil, 0.1])
        XCTAssertEqual(team.ys, [0.2, nil])

        // Should throw - needs to be attached to a Match Zebra
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        let match = insertMatch()
        let modelZebra = TBAMatchZebra(key: key, times: [0.0, 0.1], alliances: ["red": []])
        let zebra = MatchZebra.insert(modelZebra, in: persistentContainer.viewContext)
        zebra.matchRaw = match

        team.allianceRaw = zebra.alliances.first!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let teamModel = TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
        let team = MatchZebraTeam.insert("key", teamModel, in: persistentContainer.viewContext)

        // Zebra Team needs to be connected to Zebra/Zebra Alliance in order to filter properly
        let match = insertMatch()
        let modelZebra = TBAMatchZebra(key: "key", times: [0.0, 0.1], alliances: ["red": []])
        let zebra = MatchZebra.insert(modelZebra, in: persistentContainer.viewContext)
        zebra.matchRaw = match
        team.allianceRaw = zebra.alliances.first!

        XCTAssertEqual(team.team.key, "frc1")
        XCTAssertEqual(team.xs, [nil, 0.1])
        XCTAssertEqual(team.ys, [0.2, nil])

        let teamModelNew = TBAMachZebraTeam(teamKey: "frc1", xs: [0.0, 0.1], ys: [nil, 0.1])
        let newTeam = MatchZebraTeam.insert("key", teamModelNew, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(team, newTeam)

        XCTAssertEqual(team.team.key, "frc1")
        XCTAssertEqual(team.xs, [0.0, 0.1])
        XCTAssertEqual(team.ys, [nil, 0.1])
    }

    func test_delete() {
        let modelTeam = TBAMachZebraTeam(teamKey: "frc1", xs: [nil, 0.1], ys: [0.2, nil])
        let modelZebra = TBAMatchZebra(key: "key", times: [0.0, 0.1], alliances: [
            "red": [modelTeam]
        ])
        let zebra = MatchZebra.insert(modelZebra, in: persistentContainer.viewContext)
        zebra.matchRaw = insertMatch()
        let alliance = zebra.alliances.first!
        let team = alliance.teams.first!

        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        let t = team.team

        persistentContainer.viewContext.delete(team)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Zebra Team was deleted
        XCTAssertNil(team.managedObjectContext)

        // Ensure our Team was not deleted
        XCTAssertNotNil(t.managedObjectContext)

        // Ensure Zebra Alliance data was not deleted
        XCTAssertNotNil(alliance.managedObjectContext)

        // Ensure Zebra wasn't deleted
        XCTAssertNotNil(zebra.managedObjectContext)

        // Ensure Match wasn't deleted
        XCTAssertNotNil(zebra.match.managedObjectContext)
    }

    func test_isOrphaned() {
        let team = MatchZebraTeam.init(entity: MatchZebraTeam.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(team.isOrphaned)

        team.allianceRaw = MatchZebraAlliance.init(entity: MatchZebraAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertFalse(team.isOrphaned)

        team.allianceRaw = nil
        XCTAssert(team.isOrphaned)
    }

}
