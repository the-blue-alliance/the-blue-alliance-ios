import XCTest
@testable import The_Blue_Alliance

class MatchAlliance_TestCase: CoreDataTestCase {

    var alliance: MatchAlliance!

    override func setUp() {
        super.setUp()

        alliance = MatchAlliance.init(entity: MatchAlliance.entity(), insertInto: persistentContainer.viewContext)
    }

    override func tearDown() {
        alliance = nil

        super.tearDown()
    }

    func test_teams() {
        alliance.teamsJoined = "frc2337,frc7332,frc3333"
        XCTAssertEqual(alliance.teams, ["frc2337", "frc7332", "frc3333"])
    }

    func test_surrogateTeams() {
        XCTAssertNil(alliance.surrogateTeams)
        alliance.surrogateTeamsJoined = "frc7332,frc3333"
        XCTAssertEqual(alliance.surrogateTeams, ["frc7332", "frc3333"])
    }

    func test_dqTeams() {
        XCTAssertNil(alliance.dqTeams)
        alliance.dqTeamsJoined = "frc7332,frc3333"
        XCTAssertEqual(alliance.dqTeams, ["frc7332", "frc3333"])
    }

}
