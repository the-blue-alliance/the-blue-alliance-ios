import XCTest
@testable import The_Blue_Alliance

class TeamKeyTestCase: CoreDataTestCase {

    func test_insert_required() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        teamKey.key = "frc7332"
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_insert() {
        let testTeamKey = "frc7332"

        let teamKey_first = TeamKey.insert(withKey: testTeamKey, in: persistentContainer.viewContext)
        XCTAssertNotNil(teamKey_first)
        XCTAssertEqual(teamKey_first.key, testTeamKey)

        let alliance = MatchAlliance(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.addToTeams(teamKey_first)

        let teamKey_second = TeamKey.insert(withKey: testTeamKey, in: persistentContainer.viewContext)
        XCTAssertEqual(teamKey_first, teamKey_second)

        XCTAssertNotNil(teamKey_first.alliances)
        XCTAssert(alliance.teams!.contains(teamKey_second))
    }

    func test_supportsOffSeason() {
        let teamKey = TeamKey.insert(withKey: "frc7332B", in: persistentContainer.viewContext)
        XCTAssertEqual(teamKey.key, "frc7332B")
        XCTAssertEqual(teamKey.teamNumber, "7332B")
        XCTAssertEqual(teamKey.name, "Team 7332B")
        XCTAssertNil(teamKey.team)
        XCTAssertNoThrow(try persistentContainer.viewContext.save())
    }

    func test_team() {
        let teamKey = TeamKey.insert(withKey: "frc7332", in: persistentContainer.viewContext)
        XCTAssertNil(teamKey.team)

        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        Team.insert(model, in: persistentContainer.viewContext)
        XCTAssertNotNil(teamKey.team)
    }

    func test_teamNumber() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: persistentContainer.viewContext)
        teamKey.key = "frc7332"
        XCTAssertEqual(teamKey.teamNumber, "7332")
    }

    func test_name() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: persistentContainer.viewContext)
        teamKey.key = "frc7332"
        XCTAssertEqual(teamKey.name, "Team 7332")
    }

    func test_isOrphaned() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: persistentContainer.viewContext)
        // TeamKey should never be orphaned
        XCTAssertFalse(teamKey.isOrphaned)
    }

    func test_myTBASubscribable() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: persistentContainer.viewContext)
        teamKey.key = "frc1"

        XCTAssertEqual(team.modelKey, "frc1")
        XCTAssertEqual(team.modelType, .team)
        XCTAssertEqual(Team.notificationTypes.count, 5)
    }

}
