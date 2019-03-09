import XCTest
@testable import TBA

class TeamViewControllerTests: TBATestCase {

    var team: Team {
        return teamViewController.team
    }

    var teamViewController: TeamViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        let team = insertTeam()

        teamViewController = TeamViewController(team: team, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: teamViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        teamViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        verifyLayer(viewControllerTester.window.layer)

        // myTBA authed
        myTBA.authToken = "abcd123"
        verifyLayer(viewControllerTester.window.layer, identifier: "mytba")
    }

    func test_subscribableModel() {
        XCTAssertEqual(teamViewController.subscribableModel as? Team, team)
    }

    func test_delegates() {
        XCTAssertNotNil(teamViewController.navigationTitleDelegate)

        XCTAssertNotNil(teamViewController.eventsViewController.delegate)
        XCTAssertNotNil(teamViewController.mediaViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(teamViewController.navigationTitle, "Team 7332")
        XCTAssertEqual(teamViewController.navigationSubtitle, "▾ ----") // TODO: Something here
    }

    func test_showsInfo() {
        XCTAssert(teamViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamInfoViewController
        }))
    }

    func test_showsEvents() {
        XCTAssert(teamViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamEventsViewController
        }))
    }

    func test_showsMedia() {
        XCTAssert(teamViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamMediaCollectionViewController
        }))
    }

}
