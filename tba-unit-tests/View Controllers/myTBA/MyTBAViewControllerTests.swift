import TBAData
import XCTest
@testable import MyTBAKit
@testable import The_Blue_Alliance

class MyTBAViewControllerTests: TBATestCase {

    var navigationController: MockNavigationController!
    var myTBAViewController: MyTBAViewController!

    override func setUp() {
        super.setUp()

        myTBAViewController = MyTBAViewController(myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: myTBAViewController)
    }

    override func tearDown() {
        navigationController = nil
        myTBAViewController = nil

        super.tearDown()
    }

    func test_delegates() {
        XCTAssertNotNil(myTBAViewController.favoritesViewController.delegate)
        XCTAssertNotNil(myTBAViewController.subscriptionsViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(myTBAViewController.title, "myTBA")
    }

    func test_tabBar() {
        XCTAssertEqual(myTBAViewController.tabBarItem.title, "myTBA")
    }

    func test_showsFavorites() {
        myTBAViewController.viewDidLoad()
        XCTAssert(myTBAViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MyTBATableViewController<Favorite, MyTBAFavorite>
        }))
    }

    func test_showsSubscriptions() {
        myTBAViewController.viewDidLoad()
        XCTAssert(myTBAViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MyTBATableViewController<Subscription, MyTBASubscription>
        }))
    }

    func test_showsSignInView() {
        XCTAssert(myTBAViewController.view.subviews.contains(where: { (view) -> Bool in
            return view == myTBAViewController.signInViewController.view
        }))
    }

    func test_eventSelected() {
        let event = insertDistrictEvent()
        myTBAViewController.eventSelected(event)

        XCTAssert(navigationController.detailViewController is UINavigationController)
        let nav = navigationController.detailViewController as! UINavigationController
        XCTAssert(nav.viewControllers.first is EventViewController)
    }

    func test_teamSelected() {
        let team = insertTeam()
        myTBAViewController.teamSelected(team)

        XCTAssert(navigationController.detailViewController is UINavigationController)
        let nav = navigationController.detailViewController as! UINavigationController
        XCTAssert(nav.viewControllers.first is TeamViewController)
    }

    func test_myTBAObjectSelected_match() {
        let match = insertMatch()
        myTBAViewController.matchSelected(match)

        XCTAssert(navigationController.detailViewController is UINavigationController)
        let nav = navigationController.detailViewController as! UINavigationController
        XCTAssert(nav.viewControllers.first is MatchViewController)
    }
    
    func test_authenticated() {
        let ex = expectation(description: "Authenticated")
        let mock = MockMyTBAViewController(myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        mock.authenticatedExpectation = ex
        myTBA.authToken = "abcd123"
        wait(for: [ex], timeout: 1.0)
    }

    func test_unauthenticated() {
        myTBA.authToken = "abcd123"
        let ex = expectation(description: "Unauthenticated")
        let mock = MockMyTBAViewController(myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        mock.unauthenticatedExpectation = ex
        myTBA.authToken = nil
        wait(for: [ex], timeout: 1.0)
    }

}

private class MockMyTBAViewController: MyTBAViewController {

    var authenticatedExpectation: XCTestExpectation?
    var unauthenticatedExpectation: XCTestExpectation?

    override func authenticated() {
        authenticatedExpectation?.fulfill()
    }

    override func unauthenticated() {
        unauthenticatedExpectation?.fulfill()
    }

}
