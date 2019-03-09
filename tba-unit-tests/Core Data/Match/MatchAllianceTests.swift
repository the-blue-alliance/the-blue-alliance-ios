import XCTest
@testable import TBA

class MatchAllianceTestCase: CoreDataTestCase {

    func test_teamKeys() {
        let model = TBAMatchAlliance(score: 200, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let alliance = MatchAlliance.insert(model, allianceKey: "red", matchKey: "2018miket_f1m1", in: persistentContainer.viewContext)
        XCTAssertEqual(alliance.teamKeys, ["frc1", "frc2"])
    }

    func test_dqTeamKeys() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.dqTeams = NSOrderedSet(array: ["frc3", "frc2"].map({ (key) -> TeamKey in
            return TeamKey.insert(withKey: key, in: persistentContainer.viewContext)
        }))
        XCTAssertEqual(alliance.dqTeamKeys, ["frc3", "frc2"])
    }

    func test_insert() {
        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")

        let model = TBAMatchAlliance(score: 200, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let alliance = MatchAlliance.insert(model, allianceKey: "red", matchKey: matchModel.key, in: persistentContainer.viewContext)

        XCTAssertEqual(alliance.allianceKey, "red")
        XCTAssertEqual(alliance.score, 200)
        XCTAssertEqual((alliance.teams!.array as! [TeamKey]).map({ $0.key }), ["frc1", "frc2"])
        XCTAssertEqual((alliance.surrogateTeams!.array as! [TeamKey]).map({ $0.key }), ["frc3", "frc4"])
        XCTAssertEqual((alliance.dqTeams!.array as! [TeamKey]).map({ $0.key }), ["frc5", "frc6"])

        // Should throw - needs to be attached to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        alliance.match = Match.insert(matchModel, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert_no_score() {
        let matchModel = TBAMatch(key: "2018miket_f1m1", compLevel: "f", setNumber: 1, matchNumber: 1, eventKey: "2018miket")

        let model = TBAMatchAlliance(score: -1, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let alliance = MatchAlliance.insert(model, allianceKey: "red", matchKey: matchModel.key, in: persistentContainer.viewContext)

        XCTAssertEqual(alliance.allianceKey, "red")
        XCTAssertEqual(alliance.score, nil)
        XCTAssertEqual((alliance.teams!.array as! [TeamKey]).map({ $0.key }), ["frc1", "frc2"])
        XCTAssertEqual((alliance.surrogateTeams!.array as! [TeamKey]).map({ $0.key }), ["frc3", "frc4"])
        XCTAssertEqual((alliance.dqTeams!.array as! [TeamKey]).map({ $0.key }), ["frc5", "frc6"])

        // Should throw - needs to be attached to a Match
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        alliance.match = Match.insert(matchModel, in: persistentContainer.viewContext)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_update() {
        let match = Match(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.key = "2018miket_f1m1"

        let modelOne = TBAMatchAlliance(score: 200, teams: ["frc1", "frc2"], surrogateTeams: ["frc3", "frc4"], dqTeams: ["frc5", "frc6"])
        let allianceOne = MatchAlliance.insert(modelOne, allianceKey: "red", matchKey: match.key!, in: persistentContainer.viewContext)
        allianceOne.match = match

        let teams = allianceOne.teams!.array as! [TeamKey]
        let surrogateTeams = allianceOne.surrogateTeams!.array as! [TeamKey]
        let dqTeams = allianceOne.dqTeams!.array as! [TeamKey]

        let modelTwo = TBAMatchAlliance(score: -1, teams: ["frc1"], surrogateTeams: nil, dqTeams: nil)
        let allianceTwo = MatchAlliance.insert(modelTwo, allianceKey: "red", matchKey: match.key!, in: persistentContainer.viewContext)

        // Sanity check
        XCTAssertEqual(allianceOne, allianceTwo)

        // Ensure our Match Alliance got updated properly
        XCTAssertNil(allianceOne.score)
        XCTAssertEqual((allianceOne.teams!.array as! [TeamKey]).map({ $0.key }), ["frc1"])
        XCTAssertEqual(allianceOne.surrogateTeams?.count, 0)
        XCTAssertEqual(allianceOne.dqTeams?.count, 0)

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
        alliance.match = match

        let teams = alliance.teams!.array as! [TeamKey]
        let surrogateTeams = alliance.surrogateTeams!.array as! [TeamKey]
        let dqTeams = alliance.dqTeams!.array as! [TeamKey]

        persistentContainer.viewContext.delete(alliance)
        // Should throw - Match Alliance must not be related to a Match when deleting
        XCTAssertThrowsError(try persistentContainer.viewContext.save())

        match.removeFromAlliances(alliance)
        persistentContainer.viewContext.delete(alliance)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        // Ensure our Match wasn't deleted
        XCTAssertNotNil(match.managedObjectContext)

        // Ensure our Team Key objects weren't deleted
        [teams, surrogateTeams, dqTeams].forEach({
            $0.forEach({
                XCTAssertNotNil($0.managedObjectContext)
            })
        })
    }

    func test_isOrphaned() {
        let alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        XCTAssert(alliance.isOrphaned)

        let match = Match.init(entity: Match.entity(), insertInto: persistentContainer.viewContext)
        match.addToAlliances(alliance)
        XCTAssertFalse(alliance.isOrphaned)

        match.removeFromAlliances(alliance)
        XCTAssert(alliance.isOrphaned)
    }

}
