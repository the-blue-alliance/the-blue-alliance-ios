import TBAData
import XCTest
@testable import MyTBAKit
@testable import The_Blue_Alliance

class MatchViewControllerTests: TBATestCase {

    var match: Match {
        return matchViewController.match
    }

    var matchViewController: MatchViewController!

    override func setUp() {
        super.setUp()

        let match = insertMatch()

        matchViewController = MatchViewController(match: match, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    override func tearDown() {
        matchViewController = nil

        super.tearDown()
    }

    func test_title() {
        XCTAssertEqual(matchViewController.navigationTitle, "Quals 1")
        XCTAssertEqual(matchViewController.navigationSubtitle, "@ 2018ctsc_qm1")
    }

    func test_title_event() {
        let event = insertDistrictEvent()
        match.event = event
        let vc = MatchViewController(match: match, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        XCTAssertEqual(vc.navigationTitle, "Quals 1")
        XCTAssertEqual(vc.navigationSubtitle, "@ 2018 Kettering University #1 District")
    }

    func test_showsInfo() {
        matchViewController.viewDidLoad()
        XCTAssert(matchViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MatchInfoViewController
        }))
    }

    func test_showsBreakdown() {
        matchViewController.viewDidLoad()
        XCTAssert(matchViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MatchBreakdownViewController
        }))
    }

    func test_doesNotShowBreakdown() {
        let match = insertMatch(eventKey: "2014miket_qm1")
        let vc = MatchViewController(match: match, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        XCTAssertFalse(vc.children.contains(where: { (viewController) -> Bool in
            return viewController is MatchBreakdownViewController
        }))
    }

}
