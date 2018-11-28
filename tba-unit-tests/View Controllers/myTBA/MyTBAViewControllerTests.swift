import CoreData
import XCTest
@testable import The_Blue_Alliance

class MyTBAViewControllerTests: TBATestCase {

    var myTBAViewController: MyTBAViewController!
    var navigationController: MockNavigationController!

    var viewControllerTester: TBAViewControllerTester<UINavigationController>!

    override func setUp() {
        super.setUp()

        myTBAViewController = MyTBAViewController(myTBA: myTBA, remoteConfig: remoteConfig, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
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

        // Favorites - no data
        verifyLayer(viewControllerTester.window.layer, identifier: "favorites_no_data")

        // Favorites
        Favorite.insert([MyTBAFavorite(modelKey: "2018miket", modelType: .event), MyTBAFavorite(modelKey: "2018ctsc_qm1", modelType: .match), MyTBAFavorite(modelKey: "frc7332", modelType: .team)], in: persistentContainer.viewContext)
        waitOneSecond()
        verifyLayer(viewControllerTester.window.layer, identifier: "favorites_partial_data")

        myTBAViewController.segmentedControl.selectedSegmentIndex = 1
        myTBAViewController.segmentedControl.sendActions(for: UIControl.Event.valueChanged)
        // Subscriptions
        waitOneSecond()
        verifyLayer(viewControllerTester.window.layer, identifier: "subscriptions_no_data")

        Subscription.insert([MyTBASubscription(modelKey: "2018miket", modelType: .event, notifications: [.awards]), MyTBASubscription(modelKey: "2018ctsc_qm1", modelType: .match, notifications: [.matchScore]), MyTBASubscription(modelKey: "frc7332", modelType: .team, notifications: [.upcomingMatch])], in: persistentContainer.viewContext)
        waitOneSecond()
        verifyLayer(viewControllerTester.window.layer, identifier: "subscriptions_partial_data")

        myTBAViewController.isLoggingOut = true
        waitOneSecond()
        verifyLayer(viewControllerTester.window.layer, identifier: "signing_out")
    }

    func test_delegates() {
        XCTAssertNotNil(myTBAViewController.favoritesViewController.delegate)
        XCTAssertNotNil(myTBAViewController.subscriptionsViewController.delegate)
    }

    func test_title() {
        XCTAssertEqual(myTBAViewController.title, "MyTBA")
    }

    func test_tabBar() {
        XCTAssertEqual(myTBAViewController.tabBarItem.title, "MyTBA")
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
        XCTAssert(navigationController.pushedViewController is MyTBAViewController)
    }

    func test_myTBAObjectSelected_event() {
        let event = insertDistrictEvent()
        let myTBAObject = Favorite.insert(modelKey: event.key!, modelType: .event, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)
        XCTAssert(navigationController.pushedViewController is EventViewController)
    }

    func test_myTBAObjectSelected_team_noTeam() {
        let myTBAObject = Favorite.insert(modelKey: "frc7332", modelType: .team, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)
        XCTAssert(navigationController.pushedViewController is MyTBAViewController)
    }

    func test_myTBAObjectSelected_team() {
        let team = insertTeam()
        let myTBAObject = Favorite.insert(modelKey: team.key!, modelType: .team, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)
        XCTAssert(navigationController.pushedViewController is TeamViewController)
    }

    func test_myTBAObjectSelected_team_noMatch() {
        let myTBAObject = Favorite.insert(modelKey: "2018miket_qm1", modelType: .match, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)
        XCTAssert(navigationController.pushedViewController is MyTBAViewController)
    }

    func test_myTBAObjectSelected_match() {
        let match = insertMatch()
        let myTBAObject = Favorite.insert(modelKey: match.key!, modelType: .match, in: persistentContainer.viewContext)
        myTBAViewController.myTBAObjectSelected(myTBAObject)
        XCTAssert(navigationController.pushedViewController is MatchViewController)
    }
    
    func test_authenticated() {
        let ex = expectation(description: "Authenticated")
        let mock = MockMyTBAViewController(myTBA: myTBA, remoteConfig: remoteConfig, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        mock.authenticatedExpectation = ex
        myTBA.authToken = "abcd123"
        wait(for: [ex], timeout: 1.0)
    }

    func test_unauthenticated() {
        myTBA.authToken = "abcd123"
        let ex = expectation(description: "Unauthenticated")
        let mock = MockMyTBAViewController(myTBA: myTBA, remoteConfig: remoteConfig, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
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
