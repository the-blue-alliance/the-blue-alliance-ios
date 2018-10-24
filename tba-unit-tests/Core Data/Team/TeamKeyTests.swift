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

        let teamKey_second = TeamKey.insert(withKey: testTeamKey, in: persistentContainer.viewContext)
        XCTAssertEqual(teamKey_first, teamKey_second)
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

}