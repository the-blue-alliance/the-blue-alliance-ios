import TBAData
import XCTest
@testable import MyTBAKit
@testable import The_Blue_Alliance

class TeamViewControllerTests: TBATestCase {

    var team: Team {
        return teamViewController.team
    }

    var teamViewController: TeamViewController!

    override func setUp() {
        super.setUp()

        let team = insertTeam()

        teamViewController = TeamViewController(team: team, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
    }

    override func tearDown() {
        teamViewController = nil

        super.tearDown()
    }

    func test_subscribableModel() {
        XCTAssertEqual(teamViewController.subscribableModel as? Team, team)
    }

    func test_delegates() {
        XCTAssertNotNil(teamViewController.eventsViewController.delegate)
        XCTAssertNotNil(teamViewController.mediaViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(teamViewController.navigationTitle, "Team 7332")
        XCTAssertEqual(teamViewController.navigationSubtitle, "----")
    }

    func test_showsInfo() {
        teamViewController.viewDidLoad()
        XCTAssert(teamViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamInfoViewController
        }))
    }

    func test_showsEvents() {
        teamViewController.viewDidLoad()
        XCTAssert(teamViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamEventsViewController
        }))
    }

    func test_showsMedia() {
        teamViewController.viewDidLoad()
        XCTAssert(teamViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is TeamMediaCollectionViewController
        }))
    }

}
