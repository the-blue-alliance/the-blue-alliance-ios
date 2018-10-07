import XCTest
@testable import The_Blue_Alliance

class TeamsContainerViewController_TestCase: TBATestCase {

    var teamsContainerViewController: TeamsContainerViewController!
    var navigationController: MockNavigationController!

    override func setUp() {
        super.setUp()

        teamsContainerViewController = TeamsContainerViewController(remoteConfig: remoteConfig,
                                                                    urlOpener: urlOpener,
                                                                    persistentContainer: persistentContainer)
        navigationController = MockNavigationController(rootViewController: teamsContainerViewController)

        teamsContainerViewController.viewDidLoad()
    }

    override func tearDown() {
        teamsContainerViewController = nil
        navigationController = nil

        super.tearDown()
    }

    func test_delegates() {
        XCTAssertNotNil(teamsContainerViewController.teamsViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(teamsContainerViewController.title, "Teams")
    }

    func test_tabBar() {
        XCTAssertNotNil(teamsContainerViewController.tabBarItem.image)
    }

    func test_showsTeams() {
        XCTAssert(teamsContainerViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamsViewController
        }))
    }

    func test_pushTeam() {
        let team = insertTestTeam()

        let showDetailViewControllerExpectation = XCTestExpectation(description: "showDetailViewController called")
        navigationController.showDetailViewControllerCalled = { (vc) in
            XCTAssert(vc is UINavigationController)
            let nav = vc as! UINavigationController
            XCTAssert(nav.viewControllers.first is TeamViewController)

            showDetailViewControllerExpectation.fulfill()
        }
        teamsContainerViewController.teamSelected(team)

        wait(for: [showDetailViewControllerExpectation], timeout: 1.0)
    }

    func insertTestTeam() -> Team {
        // Required: key, name, teamNumber, rookieYear
        let team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.key = "frc2337"
        team.name = "General Motors/Premier Tooling Systems/Microsoft/The Chrysler Foundation/Davison Tool & Engineering, L.L.C./The Robot Space/Michigan Department of Education/Kettering University/Taylor Steel/DXC Technology/Complete Scrap/ZF North America & Grand Blanc Community High School"
        team.teamNumber = 2337
        team.rookieYear = 2008
        return team
    }

}
