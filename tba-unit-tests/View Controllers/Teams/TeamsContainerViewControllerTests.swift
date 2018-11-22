import XCTest
@testable import The_Blue_Alliance

class TeamsContainerViewControllerTests: TBATestCase {

    var teamsContainerViewController: TeamsContainerViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester!

    override func setUp() {
        super.setUp()

        teamsContainerViewController = TeamsContainerViewController(remoteConfig: remoteConfig,
                                                                    urlOpener: urlOpener,
                                                                    persistentContainer: persistentContainer,
                                                                    tbaKit: tbaKit,
                                                                    userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: teamsContainerViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: teamsContainerViewController)
    }

    override func tearDown() {
        teamsContainerViewController = nil
        navigationController = nil
        viewControllerTester = nil

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
