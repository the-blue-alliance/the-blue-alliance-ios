import TBAData
import XCTest
@testable import MyTBAKit
@testable import The_Blue_Alliance

class EventViewControllerTests: TBATestCase {

    var event: Event {
        return eventViewController.event
    }

    var navigationController: MockNavigationController!
    var eventViewController: EventViewController!

    override func setUp() {
        super.setUp()

        let event = insertDistrictEvent()

        eventViewController = EventViewController(event: event, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        navigationController = MockNavigationController(rootViewController: eventViewController)
    }

    override func tearDown() {
        navigationController = nil
        eventViewController = nil

        super.tearDown()
    }

    func test_subscribableModel() {
        XCTAssertEqual(eventViewController.subscribableModel as? Event, event)
    }

    func test_delegates() {
        XCTAssertNotNil(eventViewController.infoViewController.delegate)
        XCTAssertNotNil(eventViewController.teamsViewController.delegate)
        XCTAssertNotNil(eventViewController.rankingsViewController.delegate)
        XCTAssertNotNil(eventViewController.matchesViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(eventViewController.title, "2018 Kettering University #1 District")
    }

    func test_showsInfo() {
        eventViewController.viewDidLoad()
        XCTAssert(eventViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is EventInfoViewController
        }))
    }

    func test_showsTeams() {
        eventViewController.viewDidLoad()
        XCTAssert(eventViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is EventTeamsViewController
        }))
    }

    func test_showsRankings() {
        eventViewController.viewDidLoad()
        XCTAssert(eventViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is EventRankingsViewController
        }))
    }

    func test_showsMatches() {
        eventViewController.viewDidLoad()
        XCTAssert(eventViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MatchesViewController
        }))
    }

    func test_info_pushesAlliances() {
        eventViewController.showAlliances()

        XCTAssert(navigationController.pushedViewController is EventAlliancesContainerViewController)
        let alliancesViewController = navigationController.pushedViewController as! EventAlliancesContainerViewController
        XCTAssertEqual(alliancesViewController.event, event)
    }

    func test_info_pushesAwards() {
        eventViewController.showAwards()

        XCTAssert(navigationController.pushedViewController is EventAwardsContainerViewController)
        let awardsViewController = navigationController.pushedViewController as! EventAwardsContainerViewController
        XCTAssertEqual(awardsViewController.event, event)
    }

    func test_info_pushesDistrictPoints() {
        eventViewController.showDistrictPoints()

        XCTAssert(navigationController.pushedViewController is EventDistrictPointsContainerViewController)
        let districtPointsViewController = navigationController.pushedViewController as! EventDistrictPointsContainerViewController
        XCTAssertEqual(districtPointsViewController.event, event)
    }

    func test_info_pushesInsights() {
        eventViewController.showInsights()

        XCTAssert(navigationController.pushedViewController is EventInsightsContainerViewController)
        let statsViewController = navigationController.pushedViewController as! EventInsightsContainerViewController
        XCTAssertEqual(statsViewController.event, event)
    }

}
