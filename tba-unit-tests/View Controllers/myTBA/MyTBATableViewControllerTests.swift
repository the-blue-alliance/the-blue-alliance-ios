import CoreData
import XCTest
@testable import TBAKit
@testable import MyTBAKit
@testable import The_Blue_Alliance

class MyTBATableViewControllerTests: TBATestCase {

    var myTBATableViewController: MyTBATableViewController<Favorite, MyTBAFavorite>!
    var viewControllerTester: TBAViewControllerTester<MyTBATableViewController<Favorite, MyTBAFavorite>>!

    override func setUp() {
        super.setUp()

        myTBATableViewController = MyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        viewControllerTester = TBAViewControllerTester(withViewController: myTBATableViewController)
    }

    override func tearDown() {
        viewControllerTester = nil
        myTBATableViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        myTBATableViewController.tableView.reloadData()
        waitOneSecond()
        verifyLayer(viewControllerTester.window.layer, identifier: "no_data")

        Favorite.insert([MyTBAFavorite(modelKey: "2018miket", modelType: .event), MyTBAFavorite(modelKey: "2018ctsc_qm1", modelType: .match), MyTBAFavorite(modelKey: "frc7332", modelType: .team), MyTBAFavorite(modelKey: "2018miket_frc2337", modelType: .eventTeam), MyTBAFavorite(modelKey: "frc7332", modelType: .team)], in: persistentContainer.viewContext)
        myTBATableViewController.fetchMatch("2018ctsc_qm1")
        waitOneSecond()

        verifyLayer(viewControllerTester.window.layer, identifier: "partial_data")

        _ = insertTeam()
        _ = insertDistrictEvent()
        _ = insertMatch()
        myTBATableViewController.tableView.reloadData()

        verifyLayer(viewControllerTester.window.layer, identifier: "data")
    }

    func test_refersh_unauthenticated() {
        myTBATableViewController.refresh()
        XCTAssertEqual(myTBATableViewController.refreshOperationQueue.operations.count, 0)
    }

    func test_refresh() {
        myTBA.authToken = "abcd123"
        let mockMyTBATableViewController = MockMyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        let fetchEventExpectation = expectation(description: "Fetch event called")
        mockMyTBATableViewController.fetchEventExpectation = fetchEventExpectation
        let fetchTeamExpectation = expectation(description: "Fetch team called")
        mockMyTBATableViewController.fetchTeamExpectation = fetchTeamExpectation
        let fetchMatchExpectation = expectation(description: "Fetch match called")
        mockMyTBATableViewController.fetchMatchExpectation = fetchMatchExpectation

        mockMyTBATableViewController.refresh()
        XCTAssertEqual(mockMyTBATableViewController.refreshOperationQueue.operations.count, 1)

        let operation = mockMyTBATableViewController.refreshOperationQueue.operations.first! as! MyTBAOperation
        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: operation)
        wait(for: [saveExpectation], timeout: 1.0)

        let favories = Favorite.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(favories.count, 3)

        wait(for: [fetchEventExpectation, fetchTeamExpectation, fetchMatchExpectation], timeout: 1.0)
        XCTAssert(myTBATableViewController.refreshOperationQueue.operations.isEmpty)

        XCTAssert(mockMyTBATableViewController.hasSuccessfullyRefreshed)
    }

    func test_refresh_delete() {
        myTBA.authToken = "abcd123"

        Favorite.insert([MyTBAFavorite(modelKey: "2018miket", modelType: .event), MyTBAFavorite(modelKey: "2018ctsc_qm1", modelType: .match), MyTBAFavorite(modelKey: "frc7332", modelType: .team)], in: persistentContainer.viewContext)
        Subscription.insert(modelKey: "2018miket", modelType: .event, notifications: [.awards], in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()

        // Sanity check
        XCTAssertEqual(Favorite.fetch(in: persistentContainer.viewContext).count, 3)
        XCTAssertEqual(Subscription.fetch(in: persistentContainer.viewContext).count, 1)

        myTBATableViewController.refresh()
        let operation = myTBATableViewController.refreshOperationQueue.operations.first! as! MyTBAOperation
        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: operation, code: 201)
        wait(for: [saveExpectation], timeout: 1.0)

        XCTAssertEqual(Favorite.fetch(in: persistentContainer.viewContext).count, 0)
        XCTAssertEqual(Subscription.fetch(in: persistentContainer.viewContext).count, 1)
    }

    func test_select() {
        Favorite.insert([MyTBAFavorite(modelKey: "2018miket", modelType: .event)], in: persistentContainer.viewContext)
        waitOneSecond() // Wait for our FRC to refetch

        let ex = expectation(description: "myTBAObjectSelected called")

        let mockDelegate = MockMyTBATableViewControllerDelegate()
        mockDelegate.myTBAObjectSelectedExpectation = ex
        myTBATableViewController.delegate = mockDelegate

        myTBATableViewController.tableView(myTBATableViewController.tableView, didSelectRowAt: IndexPath(item: 0, section: 0))
        wait(for: [ex], timeout: 1.0)
    }

    func test_fetchEvent() {
        testRefresh(Event.self, key: "2017micmp", fetch: myTBATableViewController.fetchEvent)
    }

    func test_fetchEvent_nil() {
        testRefresh(Event.self, key: "2017micmp", fetch: myTBATableViewController.fetchEvent, unmodified: true)
    }

    func test_fetchTeam() {
        testRefresh(Team.self, key: "frc2337", fetch: myTBATableViewController.fetchTeam)
    }

    func test_fetchTeam_nil() {
        testRefresh(Team.self, key: "frc2337", fetch: myTBATableViewController.fetchTeam, unmodified: true)
    }

    func test_fetchMatch() {
        testRefresh(Match.self, key: "2017mike2_qm1", fetch: myTBATableViewController.fetchMatch)
    }

    func test_fetchMatch_nil() {
        testRefresh(Match.self, key: "2017mike2_qm1", fetch: myTBATableViewController.fetchMatch, unmodified: true)
    }

    // MARK: - Private testing methods

    private func testRefresh<T: Managed & NSManagedObject>(_ Type: T.Type, key: String, fetch: ((String) -> TBAKitOperation), unmodified: Bool = false) {
        // Sanity check pre-fetch
        checkKey(T.self, key: key, shouldBeNil: true)

        // Kickoff our fetch
        let operation = fetch(key)
        let task = operation.task! as! URLSessionDataTask
        XCTAssertNil(tbaKit.lastModified(task))

        // Wait for callback block and save
        let saveExpectation = backgroundContextSaveExpectation()
        if unmodified {
            tbaKit.sendUnmodifiedStub(for: operation)
        } else {
            tbaKit.sendSuccessStub(for: operation)
        }
        wait(for: [saveExpectation], timeout: 1.0)

        // Post-fetch
        checkKey(T.self, key: key, shouldBeNil: unmodified)
        XCTAssertNotNil(tbaKit.lastModified(task))
    }

    private func checkKey<T: Managed & NSManagedObject>(_ Type: T.Type, key: String, shouldBeNil: Bool = false) {
        let predicate = NSPredicate(format: "key == %@", key)
        XCTAssertEqual(T.findOrFetch(in: persistentContainer.viewContext, matching: predicate) == nil, shouldBeNil)
    }

    func test_refreshKey() {
        let favorites = MockMyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        XCTAssertEqual(favorites.refreshKey, "favorites")

        let subscriptions = MockMyTBATableViewController<Subscription, MyTBASubscription>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        XCTAssertEqual(subscriptions.refreshKey, "subscriptions")
    }

    func test_automaticRefreshInterval() {
        XCTAssertEqual(myTBATableViewController.automaticRefreshInterval?.day, 1)
    }

    func test_automaticRefreshEndDate() {
        XCTAssertNil(myTBATableViewController.automaticRefreshEndDate)
    }

    func test_isDataSourceEmpty() {
        // No objects, myTBA not auth'd
        XCTAssertFalse(myTBATableViewController.isDataSourceEmpty)

        // myTBA Auth'd, no objects
        myTBA.authToken = "abcd123"
        XCTAssert(myTBATableViewController.isDataSourceEmpty)

        // myTBA not auth'd, with objects
        myTBA.authToken = nil
        Favorite.insert([MyTBAFavorite(modelKey: "2018miket", modelType: .event)], in: persistentContainer.viewContext)
        waitOneSecond() // Wait for our FRC to refetch
        XCTAssertFalse(myTBATableViewController.isDataSourceEmpty)

        // myTBA auth'd, with objects
        myTBA.authToken = "abcd123"
        XCTAssertFalse(myTBATableViewController.isDataSourceEmpty)
    }

    func test_noDataText() {
        let favorites = MockMyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        XCTAssertEqual(favorites.noDataText, "No favorites")

        let subscriptions = MockMyTBATableViewController<Subscription, MyTBASubscription>(myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        XCTAssertEqual(subscriptions.noDataText, "Subscriptions are not yet supported")
    }

}

private class MockMyTBATableViewController<T: MyTBAEntity & MyTBAManaged, J: MyTBAModel>: MyTBATableViewController<T, J> {

    var fetchEventExpectation: XCTestExpectation?
    var fetchTeamExpectation: XCTestExpectation?
    var fetchMatchExpectation: XCTestExpectation?

    override func fetchEvent(_ key: String) -> TBAKitOperation {
        fetchEventExpectation?.fulfill()
        return super.fetchEvent(key)
    }

    override func fetchTeam(_ key: String) -> TBAKitOperation {
        fetchTeamExpectation?.fulfill()
        return super.fetchTeam(key)
    }

    override func fetchMatch(_ key: String) -> TBAKitOperation {
        fetchMatchExpectation?.fulfill()
        return super.fetchMatch(key)
    }

}

private class MockMyTBATableViewControllerDelegate: NSObject, MyTBATableViewControllerDelegate {

    var myTBAObjectSelectedExpectation: XCTestExpectation?

    func myTBAObjectSelected(_ myTBAObject: MyTBAEntity) {
        myTBAObjectSelectedExpectation?.fulfill()
    }

}
