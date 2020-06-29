import CoreData
import XCTest
@testable import TBAData
@testable import TBAKit
@testable import MyTBAKit
@testable import The_Blue_Alliance

class MyTBATableViewControllerTests: TBATestCase {

    var myTBATableViewController: MyTBATableViewController<Favorite, MyTBAFavorite>!

    override func setUp() {
        super.setUp()

        myTBATableViewController = MyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, dependencies: dependencies)
        myTBATableViewController.viewDidLoad()
    }

    override func tearDown() {
        myTBATableViewController = nil

        super.tearDown()
    }

    func test_refersh_unauthenticated() {
        myTBATableViewController.refresh()
        XCTAssertEqual(myTBATableViewController.refreshOperationQueue.operations.count, 0)
    }

    func test_refresh() {
        myTBA.authToken = "abcd123"
        let mockMyTBATableViewController = MockMyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, dependencies: dependencies)

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

        let event = insertEvent()
        Favorite.insert([MyTBAFavorite(modelKey: event.key, modelType: .event), MyTBAFavorite(modelKey: "2018ctsc_qm1", modelType: .match), MyTBAFavorite(modelKey: "frc7332", modelType: .team)], in: persistentContainer.viewContext)
        Subscription.insert(modelKey: event.key, modelType: .event, notifications: [.awards], in: persistentContainer.viewContext)
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
        let event = insertEvent()
        Favorite.insert([MyTBAFavorite(modelKey: event.key, modelType: .event)], in: persistentContainer.viewContext)
        waitOneSecond() // Wait for our FRC to refetch

        let ex = expectation(description: "eventSelectedExpectation called")

        let mockDelegate = MockMyTBATableViewControllerDelegate()
        mockDelegate.eventSelectedExpectation = ex
        myTBATableViewController.delegate = mockDelegate

        myTBATableViewController.tableView(myTBATableViewController.tableView, didSelectRowAt: IndexPath(item: 0, section: 0))
        wait(for: [ex], timeout: 1.0)
    }

    func test_fetchEvent() {
        let model = MyTBAFavorite(modelKey: "2017micmp", modelType: .event)
        testRefresh(Event.self, model: model, fetch: myTBATableViewController.fetchEvent)
    }

    func test_fetchTeam() {
        let model = MyTBAFavorite(modelKey: "frc2337", modelType: .team)
        testRefresh(Team.self, model: model, fetch: myTBATableViewController.fetchTeam)
    }

    func test_fetchMatch() {
        let model = MyTBAFavorite(modelKey: "2017mike2_qm1", modelType: .match)
        testRefresh(Match.self, model: model, fetch: myTBATableViewController.fetchMatch)
    }

    // MARK: - Private testing methods

    private func testRefresh<T: Managed & NSManagedObject>(_ Type: T.Type, model: MyTBAModel, fetch: ((MyTBAModel) -> TBAKitOperation), unmodified: Bool = false) {
        let key = model.modelKey

        // Sanity check pre-fetch
        checkKey(T.self, key: key, shouldBeNil: true)

        // Kickoff our fetch
        let operation = fetch(model)
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
        let predicate = NSPredicate(format: "keyRaw == %@", key)
        XCTAssertEqual(T.findOrFetch(in: persistentContainer.viewContext, matching: predicate) == nil, shouldBeNil)
    }

    func test_refreshKey() {
        let favorites = MockMyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, dependencies: dependencies)
        XCTAssertEqual(favorites.refreshKey, "favorites")

        let subscriptions = MockMyTBATableViewController<Subscription, MyTBASubscription>(myTBA: myTBA, dependencies: dependencies)
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

        let event = insertEvent()
        Favorite.insert([MyTBAFavorite(modelKey: event.key, modelType: .event)], in: persistentContainer.viewContext)

        waitOneSecond() // Wait for our FRC to refetch
        XCTAssertFalse(myTBATableViewController.isDataSourceEmpty)

        // myTBA auth'd, with objects
        myTBA.authToken = "abcd123"
        XCTAssertFalse(myTBATableViewController.isDataSourceEmpty)
    }

    func test_noDataText() {
        let favorites = MockMyTBATableViewController<Favorite, MyTBAFavorite>(myTBA: myTBA, dependencies: dependencies)
        XCTAssertEqual(favorites.noDataText, "No favorites")

        let subscriptions = MockMyTBATableViewController<Subscription, MyTBASubscription>(myTBA: myTBA, dependencies: dependencies)
        XCTAssertEqual(subscriptions.noDataText, "No subscriptions")
    }

}

private class MockMyTBATableViewController<T: MyTBAEntity & MyTBAManaged, J: MyTBAModel>: MyTBATableViewController<T, J> {

    var fetchEventExpectation: XCTestExpectation?
    var fetchTeamExpectation: XCTestExpectation?
    var fetchMatchExpectation: XCTestExpectation?

    override func fetchEvent(_ myTBAModel: MyTBAModel) -> TBAKitOperation {
        fetchEventExpectation?.fulfill()
        return super.fetchEvent(myTBAModel)
    }

    override func fetchTeam(_ myTBAModel: MyTBAModel) -> TBAKitOperation {
        fetchTeamExpectation?.fulfill()
        return super.fetchTeam(myTBAModel)
    }

    override func fetchMatch(_ myTBAModel: MyTBAModel) -> TBAKitOperation {
        fetchMatchExpectation?.fulfill()
        return super.fetchMatch(myTBAModel)
    }

}

private class MockMyTBATableViewControllerDelegate: NSObject, MyTBATableViewControllerDelegate {

    var eventSelectedExpectation: XCTestExpectation?
    var teamSelectedExpectation: XCTestExpectation?
    var matchSelectedExpectation: XCTestExpectation?

    func eventSelected(_ event: Event) {
        eventSelectedExpectation?.fulfill()
    }

    func teamSelected(_ team: Team) {
        teamSelectedExpectation?.fulfill()
    }

    func matchSelected(_ match: Match) {
        matchSelectedExpectation?.fulfill()
    }

}
