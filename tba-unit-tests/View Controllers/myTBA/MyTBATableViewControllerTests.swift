import CoreData
import XCTest
@testable import The_Blue_Alliance

class MyTBATableViewControllerTests: TBATestCase {

    var myTBATableViewController: MyTBATableViewController<Favorite, MyTBAFavorite>!
    var viewControllerTester: TBAViewControllerTester<MyTBATableViewController<Favorite, MyTBAFavorite>>!

    override func setUp() {
        super.setUp()

        myTBATableViewController = MyTBATableViewController<Favorite, MyTBAFavorite>(persistentContainer: persistentContainer, myTBA: myTBA, tbaKit: tbaKit, userDefaults: userDefaults)

        viewControllerTester = TBAViewControllerTester(withViewController: myTBATableViewController)
    }

    override func tearDown() {
        viewControllerTester = nil
        myTBATableViewController = nil

        super.tearDown()
    }

    func test_snapshot() {
        myTBATableViewController.tableView.reloadData()
        waitForAnimations()
        verifyLayer(viewControllerTester.window.layer, identifier: "no_data")

        Favorite.insert([MyTBAFavorite(modelKey: "2018miket", modelType: .event), MyTBAFavorite(modelKey: "2018ctsc_qm1", modelType: .match), MyTBAFavorite(modelKey: "frc7332", modelType: .team)], in: persistentContainer.viewContext)
        try! persistentContainer.viewContext.save()
        waitForAnimations()

        verifyLayer(viewControllerTester.window.layer, identifier: "partial_data")

        _ = insertTeam()
        _ = insertDistrictEvent()
        myTBATableViewController.tableView.reloadData()

        verifyLayer(viewControllerTester.window.layer, identifier: "data")
    }

    func test_refresh() {
        let mockMyTBATableViewController = MockMyTBATableViewController<Favorite, MyTBAFavorite>(persistentContainer: persistentContainer, myTBA: myTBA, tbaKit: tbaKit, userDefaults: userDefaults)

        let fetchEventExpectation = expectation(description: "Fetch event called")
        mockMyTBATableViewController.fetchEventExpectation = fetchEventExpectation
        let fetchTeamExpectation = expectation(description: "Fetch team called")
        mockMyTBATableViewController.fetchTeamExpectation = fetchTeamExpectation
        let fetchMatchExpectation = expectation(description: "Fetch match called")
        mockMyTBATableViewController.fetchMatchExpectation = fetchMatchExpectation

        mockMyTBATableViewController.refresh()
        XCTAssertEqual(mockMyTBATableViewController.requests.count, 1)

        let task = mockMyTBATableViewController.requests.first!
        let saveExpectation = backgroundContextSaveExpectation()
        myTBA.sendStub(for: task)
        wait(for: [saveExpectation], timeout: 1.0)

        let favories = Favorite.fetch(in: persistentContainer.viewContext)
        XCTAssertEqual(favories.count, 3)

        wait(for: [fetchEventExpectation, fetchTeamExpectation, fetchMatchExpectation], timeout: 1.0)
        XCTAssert(mockMyTBATableViewController.requests.isEmpty)
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

    private func testRefresh<T: Managed & NSManagedObject>(_ Type: T.Type, key: String, fetch: (String) -> (URLSessionDataTask), unmodified: Bool = false) {
        // Sanity check pre-fetch
        checkFetchKeys(key, shouldContainKey: false)
        checkKey(T.self, key: key, shouldBeNil: true)

        // Kickoff our fetch
        let request = fetch(key)
        checkFetchKeys(key)
        XCTAssertNil(tbaKit.lastModified(request))

        // Wait for callback block and save
        let saveExpectation = backgroundContextSaveExpectation()
        if unmodified {
            tbaKit.sendUnmodifiedStub(for: request)
        } else {
            tbaKit.sendSuccessStub(for: request)
        }
        wait(for: [saveExpectation], timeout: 1.0)

        // Post-fetch
        checkKey(T.self, key: key, shouldBeNil: unmodified)
        checkFetchKeys(key, shouldContainKey: false)
        XCTAssertNotNil(tbaKit.lastModified(request))
    }

    private func checkKey<T: Managed & NSManagedObject>(_ Type: T.Type, key: String, shouldBeNil: Bool = false) {
        let predicate = NSPredicate(format: "key == %@", key)
        XCTAssertEqual(T.findOrFetch(in: persistentContainer.viewContext, matching: predicate) == nil, shouldBeNil)
    }

    private func checkFetchKeys(_ key: String, shouldContainKey: Bool = true) {
        if shouldContainKey {
            XCTAssert(myTBATableViewController.backgroundFetchKeys.contains(key))
        } else {
            XCTAssertFalse(myTBATableViewController.backgroundFetchKeys.contains(key))
        }
        // Check that we don't add the request to our refreshing
        XCTAssert(myTBATableViewController.requests.isEmpty)
    }

}

private class MockMyTBATableViewController<T: MyTBAEntity & MyTBAManaged, J: MyTBAModel>: MyTBATableViewController<T, J> {

    var fetchEventExpectation: XCTestExpectation?
    var fetchTeamExpectation: XCTestExpectation?
    var fetchMatchExpectation: XCTestExpectation?

    override func fetchEvent(_ key: String) -> URLSessionDataTask {
        fetchEventExpectation?.fulfill()
        return super.fetchEvent(key)
    }

    override func fetchTeam(_ key: String) -> URLSessionDataTask {
        fetchTeamExpectation?.fulfill()
        return super.fetchTeam(key)
    }

    override func fetchMatch(_ key: String) -> URLSessionDataTask {
        fetchMatchExpectation?.fulfill()
        return super.fetchMatch(key)
    }

}
