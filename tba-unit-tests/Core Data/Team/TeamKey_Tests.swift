import XCTest
@testable import The_Blue_Alliance

class TeamKey_TestCase: CoreDataTestCase {

    func test_insert_required() {
        let teamKey = TeamKey.init(entity: TeamKey.entity(), insertInto: persistentContainer.viewContext)
        XCTAssertThrowsError(try persistentContainer.viewContext.save())
        teamKey.key = "frc7332"
        XCTAssertNoThrow(try persistentContainer.viewContext.save())

        addTeardownBlock {
            self.persistentContainer.viewContext.delete(teamKey)
            try! self.persistentContainer.viewContext.save()
        }
    }

    func test_insert() {
        let testTeamKey = "frc7332"

        let teamKey_first = TeamKey.insert(withKey: testTeamKey, in: persistentContainer.viewContext)
        XCTAssertNotNil(teamKey_first)
        XCTAssertEqual(teamKey_first.key, testTeamKey)

        let teamKey_second = TeamKey.insert(withKey: testTeamKey, in: persistentContainer.viewContext)
        XCTAssertEqual(teamKey_first, teamKey_second)
    }

}
