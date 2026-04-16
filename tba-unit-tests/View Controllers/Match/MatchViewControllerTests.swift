import XCTest
@testable import MyTBAKit
@testable import TBAData
@testable import The_Blue_Alliance

class MatchViewControllerTests: TBATestCase {

    var matchKey: String = ""
    var matchViewController: MatchViewController!

    override func setUp() {
        super.setUp()

        let match = insertMatch()
        matchKey = match.key

        matchViewController = MatchViewController(matchKey: match.key, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
    }

    override func tearDown() {
        matchViewController = nil

        super.tearDown()
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

}
