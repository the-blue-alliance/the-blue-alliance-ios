import XCTest
@testable import The_Blue_Alliance

class TeamsContainerViewControllerTests: TBATestCase {

    var navigationController: MockNavigationController!
    var teamsContainerViewController: TeamsContainerViewController!

    override func setUp() {
        super.setUp()

        teamsContainerViewController = TeamsContainerViewController(myTBA: myTBA,
                                                                    searchService: searchService,
                                                                    statusService: statusService,
                                                                    urlOpener: urlOpener,
                                                                    dependencies: dependencies)
        navigationController = MockNavigationController(rootViewController: teamsContainerViewController)
    }

    override func tearDown() {
        navigationController = nil
        teamsContainerViewController = nil

        super.tearDown()
    }

    func test_delegates() {
        XCTAssertNotNil(teamsContainerViewController.teamsViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(teamsContainerViewController.title, "Teams")
    }

    func test_tabBar() {
        XCTAssertEqual(teamsContainerViewController.tabBarItem.title, "Teams")
    }

    func test_showsTeams() {
        teamsContainerViewController.viewDidLoad()
        XCTAssert(teamsContainerViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamsViewController
        }))
    }

    func test_teams_pushTeam() {
        let team = insertTeam()

        teamsContainerViewController.teamSelected(team)
        XCTAssert(navigationController.pushedViewController is TeamViewController)

        let teamViewController = navigationController.pushedViewController as! TeamViewController
        XCTAssertEqual(teamViewController.team, team)
    }

}
