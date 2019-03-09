import XCTest
import FirebaseMessaging
@testable import TBA

class MyTBAViewControllerTests: TBATestCase {

    var myTBAViewController: MyTBAViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        myTBAViewController = MyTBAViewController(messaging: Messaging.messaging(), myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController = MockNavigationController(rootViewController: myTBAViewController)

        viewControllerTester = TBAViewControllerTester(withViewController: navigationController)
    }

    override func tearDown() {
        viewControllerTester = nil
        navigationController = nil
        myTBAViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        verifyLayer(viewControllerTester.window.layer, identifier: "signed_out")

        myTBA.authToken = "abcd123"
        waitOneSecond()
        verifyLayer(viewControllerTester.window.layer, identifier: "signed_in")

        myTBAViewController.isLoggingOut = true
        waitOneSecond()
        verifyLayer(viewControllerTester.window.layer, identifier: "signing_out")
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
        XCTAssert(myTBAViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MyTBATableViewController<Favorite, MyTBAFavorite>
        }))
    }

    func test_showsSubscriptions() {
        XCTAssert(myTBAViewController.children.contains(where: { (viewController) -> Bool in
            return viewController is MyTBATableViewController<Subscription, MyTBASubscription>
        }))
    }

    func test_showsSignInView() {
        XCTAssert(myTBAViewController.view.subviews.contains(where: { (view) -> Bool in
            return view == myTBAViewController.signInViewController.view
        }))
    }

    func test_myTBAObjectSelected_event_noEvent() {
        let myTBAObject = Favorite.insert(modelKey: "2018miket", modelType: .event, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)
        XCTAssertNil(navigationController.detailViewController)
    }

    func test_myTBAObjectSelected_event() {
        let event = insertDistrictEvent()
        let myTBAObject = Favorite.insert(modelKey: event.key!, modelType: .event, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)

        XCTAssert(navigationController.detailViewController is UINavigationController)
        let nav = navigationController.detailViewController as! UINavigationController
        XCTAssert(nav.viewControllers.first is EventViewController)
    }

    func test_myTBAObjectSelected_team_noTeam() {
        let myTBAObject = Favorite.insert(modelKey: "frc7332", modelType: .team, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)
        XCTAssertNil(navigationController.detailViewController)
    }

    func test_myTBAObjectSelected_team() {
        let team = insertTeam()
        let myTBAObject = Favorite.insert(modelKey: team.key!, modelType: .team, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)

        XCTAssert(navigationController.detailViewController is UINavigationController)
        let nav = navigationController.detailViewController as! UINavigationController
        XCTAssert(nav.viewControllers.first is TeamViewController)
    }

    func test_myTBAObjectSelected_team_noMatch() {
        let myTBAObject = Favorite.insert(modelKey: "2018miket_qm1", modelType: .match, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)
        XCTAssertNil(navigationController.detailViewController)
    }

    func test_myTBAObjectSelected_match() {
        let match = insertMatch()
        let myTBAObject = Favorite.insert(modelKey: match.key!, modelType: .match, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)

        XCTAssert(navigationController.detailViewController is UINavigationController)
        let nav = navigationController.detailViewController as! UINavigationController
        XCTAssert(nav.viewControllers.first is MatchViewController)
    }
    
    func test_authenticated() {
        let ex = expectation(description: "Authenticated")
        let mock = MockMyTBAViewController(messaging: Messaging.messaging(), myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        mock.authenticatedExpectation = ex
        myTBA.authToken = "abcd123"
        wait(for: [ex], timeout: 1.0)
    }

    func test_unauthenticated() {
        myTBA.authToken = "abcd123"
        let ex = expectation(description: "Unauthenticated")
        let mock = MockMyTBAViewController(messaging: Messaging.messaging(), myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
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
