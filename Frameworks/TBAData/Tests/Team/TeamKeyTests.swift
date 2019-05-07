import TBAData
import TBAKit
import XCTest

class TeamKeyTestCase: TBADataTestCase {

    func test_insert_required() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: viewContext)
        XCTAssertThrowsError(try viewContext.save())
        teamKey.key = "frc7332"
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_insert() {
        let testTeamKey = "frc7332"

        let teamKey_first = TeamKey.insert(withKey: testTeamKey, in: viewContext)
        XCTAssertNotNil(teamKey_first)
        XCTAssertEqual(teamKey_first.key, testTeamKey)

        let alliance = MatchAlliance(entity: MatchAlliance.entity(), insertInto: viewContext)
        alliance.addToTeams(teamKey_first)

        let teamKey_second = TeamKey.insert(withKey: testTeamKey, in: viewContext)
        XCTAssertEqual(teamKey_first, teamKey_second)

        XCTAssertNotNil(teamKey_first.alliances)
        XCTAssert(alliance.teams!.contains(teamKey_second))
    }

    func test_supportsOffSeason() {
        let teamKey = TeamKey.insert(withKey: "frc7332B", in: viewContext)
        XCTAssertEqual(teamKey.key, "frc7332B")
        XCTAssertEqual(teamKey.teamNumber, "7332B")
        XCTAssertEqual(teamKey.name, "Team 7332B")
        XCTAssertNil(teamKey.team)
        XCTAssertNoThrow(try viewContext.save())
    }

    func test_team() {
        let teamKey = TeamKey.insert(withKey: "frc7332", in: viewContext)
        XCTAssertNil(teamKey.team)

        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        Team.insert(model, in: viewContext)
        XCTAssertNotNil(teamKey.team)
    }

    func test_teamNumber() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: viewContext)
        teamKey.key = "frc7332"
        XCTAssertEqual(teamKey.teamNumber, "7332")
    }

    func test_name() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: viewContext)
        teamKey.key = "frc7332"
        XCTAssertEqual(teamKey.name, "Team 7332")
    }

    func test_isOrphaned() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: viewContext)
        // TeamKey should never be orphaned
        XCTAssertFalse(teamKey.isOrphaned)
    }

}
