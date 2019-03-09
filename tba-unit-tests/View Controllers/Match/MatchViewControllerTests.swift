import XCTest
@testable import TBA

class MatchViewControllerTests: TBATestCase {

    var match: Match {
        return matchViewController.match
    }

    var matchViewController: MatchViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        let match = insertMatch()

        matchViewController = MatchViewController(match: match, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: matchViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        matchViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        verifyLayer(viewControllerTester.window.layer)

        // myTBA authed
        myTBA.authToken = "abcd123"
        verifyLayer(viewControllerTester.window.layer, identifier: "mytba")
    }

    func test_title() {
        XCTAssertEqual(matchViewController.navigationTitle, "Quals 1")
        XCTAssertEqual(matchViewController.navigationSubtitle, "@ 2018ctsc_qm1")
    }

    func test_title_event() {
        let event = insertDistrictEvent()
        match.event = event
        let vc = MatchViewController(match: match, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        XCTAssertEqual(vc.navigationTitle, "Quals 1")
        XCTAssertEqual(vc.navigationSubtitle, "@ 2018 Kettering University #1 District")
    }

    func test_showsInfo() {
        XCTAssert(matchViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MatchInfoViewController
        }))
    }

    func test_showsBreakdown() {
        XCTAssert(matchViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MatchBreakdownViewController
        }))
    }

    func test_doesNotShowBreakdown() {
        let match = insertMatch(eventKey: "2014miket_qm1")
        let vc = MatchViewController(match: match, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        XCTAssertFalse(vc.children.contains(where: { (viewController) -> Bool in
            return viewController is MatchBreakdownViewController
        }))
    }

}
