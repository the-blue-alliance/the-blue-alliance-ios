import CoreData
import TBAKit
import XCTest
@testable import TBAData

class MatchAllianceTestCase: TBADataTestCase {

    func test_allianceKey() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.allianceKeyRaw = "red"
        XCTAssertEqual(alliance.allianceKey, "red")
    }

    func test_score() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertNil(alliance.score)
        alliance.scoreRaw = NSNumber(value: 2)
        XCTAssertEqual(alliance.score, 2)
    }

    func test_dqTeams() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(alliance.dqTeams.count, 0)
        let team = insertTeam()
        alliance.dqTeamsRaw = NSOrderedSet(array: [team])
        XCTAssertEqual(alliance.dqTeams.array as? [Team], [team])
    }

    func test_match() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        let match = insertMatch()
        alliance.matchRaw = match
        XCTAssertEqual(alliance.match, match)
    }

    func test_surrogateTeams() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(alliance.surrogateTeams.count, 0)
        let team = insertTeam()
        alliance.surrogateTeamsRaw = NSOrderedSet(array: [team])
        XCTAssertEqual(alliance.surrogateTeams.array as? [Team], [team])
    }

    func test_teams() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertEqual(alliance.teams.count, 0)
        let team = insertTeam()
        alliance.teamsRaw = NSOrderedSet(array: [team])
        XCTAssertEqual(alliance.teams.array as? [Team], [team])
    }

    func test_teamKeys() {
        let model = TBAMatchAlliance(score: 200, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let alliance = MatchAlliance.insert(model, allianceKey: "red", matchKey: "2018miket_f1m1", in: persistentContainer.viewContext)
        XCTAssertEqual(alliance.teamKeys, ["frc1", "frc2"])
    }

    func test_dqTeamKeys() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.dqTeamsRaw = NSOrderedSet(array: ["frc3", "frc2"].map {
            return Team.insert($0, in: persistentContainer.viewContext)
        })
        XCTAssertEqual(alliance.dqTeamKeys, ["frc3", "frc2"])
    }

    func test_surrogateTeamKeys() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.surrogateTeamsRaw = NSOrderedSet(array: ["frc2", "frc1"].map {
            return Team.insert($0, in: persistentContainer.viewContext)
        })
        XCTAssertEqual(alliance.surrogateTeamKeys, ["frc2", "frc1"])
    }

    func test_fetchRequest() {
        let fr: NSFetchRequest<MatchAlliance> = MatchAlliance.fetchRequest()
        XCTAssertEqual(fr.entityName, MatchAlliance.entityName)
    }

    func test_insert() {
        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")

        let model = TBAMatchAlliance(score: 200, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let alliance = MatchAlliance.insert(model, allianceKey: "red", matchKey: matchModel.key, in: persistentContainer.viewContext)

        XCTAssertEqual(alliance.allianceKey, "red")
        XCTAssertEqual(alliance.score, 200)
        XCTAssertEqual(alliance.teamKeys, ["frc1", "frc2"])
        XCTAssertEqual(alliance.surrogateTeamKeys, ["frc3", "frc4"])
        XCTAssertEqual(alliance.dqTeamKeys, ["frc5", "frc6"])

        // Should throw - needs to be attached to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        alliance.matchRaw = Match.insert(matchModel, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_no_score() {
        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")

        let model = TBAMatchAlliance(score: -1, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let alliance = MatchAlliance.insert(model, allianceKey: "red", matchKey: matchModel.key, in: persistentContainer.viewContext)

        XCTAssertEqual(alliance.allianceKey, "red")
        XCTAssertEqual(alliance.score, nil)
        XCTAssertEqual(alliance.teamKeys, ["frc1", "frc2"])
        XCTAssertEqual(alliance.surrogateTeamKeys, ["frc3", "frc4"])
        XCTAssertEqual(alliance.dqTeamKeys, ["frc5", "frc6"])

        // Should throw - needs to be attached to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        alliance.matchRaw = Match.insert(matchModel, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let match = Match(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.keyRaw = "2018miket_f1m1"

        let modelOne = TBAMatchAlliance(score: 200, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let allianceOne = MatchAlliance.insert(modelOne, allianceKey: "red", matchKey: match.key, in: persistentContainer.viewContext)
        allianceOne.matchRaw = match

        let teams = allianceOne.teams.array as! [Team]
        let surrogateTeams = allianceOne.surrogateTeams.array as! [Team]
        let dqTeams = allianceOne.dqTeams.array as! [Team]

        let modelTwo = TBAMatchAlliance(score: -1, teams: ["frc1"], surrogateTeams: nil, dqTeams: nil)
        let allianceTwo = MatchAlliance.insert(modelTwo, allianceKey: "red", matchKey: match.key, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(allianceOne, allianceTwo)

        // Ensure our Match Alliance got updated properly
        XCTAssertNil(allianceOne.score)
        XCTAssertEqual(allianceOne.teamKeys, ["frc1"])
        XCTAssertEqual(allianceOne.surrogateTeams.count, 0)
        XCTAssertEqual(allianceOne.dqTeams.count, 0)

        // Ensure our Team Key objects weren't deleted
        [teams, surrogateTeams, dqTeams].forEach({
            $0.forEach({
                XCTAssertNotNil($0.managedObjectContext)
            })
        })
    }

    func test_delete() {
        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")

        let model = TBAMatchAlliance(score: 200, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let alliance = MatchAlliance.insert(model, allianceKey: "red", matchKey: matchModel.key, in: persistentContainer.viewContext)

        let match = Match.insert(matchModel, in: persistentContainer.viewContext)
        alliance.matchRaw = match

        let teams = alliance.teams
        let surrogateTeams = alliance.surrogateTeams.array as! [Team]
        let dqTeams = alliance.dqTeams.array as! [Team]

        persistentContainer.viewContext.delete(alliance)
        // Should throw - Match Alliance must not be related to a Match when deleting
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        match.removeFromAlliancesRaw(alliance)
        persistentContainer.viewContext.delete(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Match wasn't deleted
        XCTAssertNotNil(match.managedObjectContext)

        // Ensure our Team Key objects weren't deleted
        [teams.array as! [Team], surrogateTeams, dqTeams].forEach({
            $0.forEach({
                XCTAssertNotNil($0.managedObjectContext)
            })
        })
    }

    func test_isOrphaned() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(alliance.isOrphaned)

        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.addToAlliancesRaw(alliance)
        XCTAssertFalse(alliance.isOrphaned)

        match.removeFromAlliancesRaw(alliance)
        XCTAssert(alliance.isOrphaned)
    }

}
