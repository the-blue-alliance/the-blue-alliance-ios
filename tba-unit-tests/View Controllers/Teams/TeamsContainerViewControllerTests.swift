import XCTest
@testable import The_Blue_Alliance

class TeamsContainerViewControllerTests: TBATestCase {

    var navigationController: MockNavigationController!
    var teamsContainerViewController: TeamsContainerViewController!

    override func setUp() {
        super.setUp()

        teamsContainerViewController = TeamsContainerViewController(messaging: messaging,
                                                                    myTBA: myTBA,
                                                                    statusService: statusService,
                                                                    urlOpener: urlOpener,
                                                                    persistentContainer: persistentContainer,
                                                                    tbaKit: tbaKit,
                                                                    userDefaults: userDefaults)
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

        XCTAssert(navigationController.detailViewController is UINavigationController)
        let nav = navigationController.detailViewController as! UINavigationController
        XCTAssert(nav.viewControllers.first is TeamViewController)
        let teamViewController = nav.viewControllers.first as! TeamViewController
        XCTAssertEqual(teamViewController.team, team)
    }

}
