import XCTest
import TBAOperationTesting
@testable import The_Blue_Alliance

class MockRefreshable: Refreshable {

    var userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: - Mock Expectations

    var updateRefreshExpectation: XCTestExpectation?

    var hideNoDataExpectation: XCTestExpectation?

    var noDataReloadExpectation: XCTestExpectation?

    var mockRefreshKey: String?

    var mockAutomaticRefreshInterval: DateComponents?

    var mockAutomaticRefreshEndDate: Date?

    // MARK: - Protocol

    var refreshOperationQueue: OperationQueue = OperationQueue()

    var refreshControl: UIRefreshControl?

    var refreshView: UIScrollView {
        return UIScrollView()
    }

    var refreshKey: String? {
        return mockRefreshKey ?? "test_refresh_key"
    }

    var automaticRefreshInterval: DateComponents? {
        return mockAutomaticRefreshInterval
    }

    var automaticRefreshEndDate: Date? {
        return mockAutomaticRefreshEndDate
    }

    var isDataSourceEmpty: Bool = false

    func refresh() {
        // TODO: Pass
    }

    func hideNoData() {
        hideNoDataExpectation?.fulfill()
    }

    func noDataReload() {
        noDataReloadExpectation?.fulfill()
    }

    func updateRefresh() {
        updateRefreshExpectation?.fulfill()
    }

}

class RefreshableTests: TBATestCase {

    var refreshable: MockRefreshable!

    override func setUp() {
        super.setUp()

        refreshable = MockRefreshable(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.clearSuccessfulRefreshes()
        refreshable = nil

        super.tearDown()
    }

    func test_shouldRefresh_isRefreshing() {
        refreshable.isDataSourceEmpty = true

        let neverFinishOp = Operation()
        let op = Operation()
        op.addDependency(neverFinishOp)
        refreshable.addRefreshOperations([op])

        XCTAssertFalse(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_hasDataBeenRefreshed() {
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_isDataSourceEmpty() {
        refreshable.markRefreshSuccessful()
        refreshable.isDataSourceEmpty = true
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_dataNotStale() {
        refreshable.markRefreshSuccessful()
        refreshable.mockAutomaticRefreshInterval = DateComponents(hour: 1)
        XCTAssertFalse(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_noEndDate() {
        refreshable.markRefreshSuccessful(Calendar.current.date(byAdding: DateComponents(hour: -1, minute: -1), to: Date())!)
        refreshable.mockAutomaticRefreshInterval = DateComponents(hour: 1)
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_beforeEndDate() {
        refreshable.markRefreshSuccessful(Calendar.current.date(byAdding: DateComponents(hour: -1, minute: -1), to: Date())!)
        refreshable.mockAutomaticRefreshInterval = DateComponents(hour: 1)
        refreshable.mockAutomaticRefreshEndDate = Calendar.current.date(byAdding: DateComponents(hour: 1), to: Date())
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_afterEndDate() {
        refreshable.markRefreshSuccessful(Calendar.current.date(byAdding: DateComponents(hour: -1, minute: -1), to: Date())!)
        refreshable.mockAutomaticRefreshInterval = DateComponents(hour: 1)
        refreshable.mockAutomaticRefreshEndDate = Calendar.current.date(byAdding: DateComponents(hour: -1), to: Date())
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_afterEndDate_lastRefreshBeforeEndDate() {
        refreshable.markRefreshSuccessful(Calendar.current.date(byAdding: DateComponents(hour: -1), to: Date())!)
        refreshable.mockAutomaticRefreshInterval = DateComponents(minute: 30)
        refreshable.mockAutomaticRefreshEndDate = Calendar.current.date(byAdding: DateComponents(hour: -1, minute: -1), to: Date())
        XCTAssertFalse(refreshable.shouldRefresh())
    }

    func test_markRefreshSuccessful() {
        XCTAssert(refreshable.shouldRefresh())

        refreshable.markRefreshSuccessful()
        XCTAssertFalse(refreshable.shouldRefresh())
    }

    func test_hasSuccessfullyRefreshed() {
        XCTAssertFalse(refreshable.hasSuccessfullyRefreshed)
        refreshable.markRefreshSuccessful()
        XCTAssert(refreshable.hasSuccessfullyRefreshed)
    }

    func test_clearSuccessfulRefreshes() {
        XCTAssert(refreshable.shouldRefresh())
        refreshable.markRefreshSuccessful()
        XCTAssertFalse(refreshable.shouldRefresh())
        userDefaults.clearSuccessfulRefreshes()
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_isRefreshing() {
        let neverFinishOp = Operation()
        let op = Operation()
        op.addDependency(neverFinishOp)

        refreshable.addRefreshOperations([op])
        XCTAssert(refreshable.isRefreshing)
    }

    func test_cancelRefresh_noRequests() {
        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh not called")
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        XCTAssert(refreshable.refreshOperationQueue.operations.isEmpty)

        refreshable.cancelRefresh()
        wait(for: [updateRefreshExpectation], timeout: 1.0)
    }

    func test_cancelRefresh() {
        let neverFinishOp = Operation()
        let op = Operation()
        op.addDependency(neverFinishOp)

        refreshable.addRefreshOperations([op])
        XCTAssertEqual(refreshable.refreshOperationQueue.operations.count, 1)

        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh called")
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        XCTAssertFalse(refreshable.refreshOperationQueue.operations.isEmpty)

        refreshable.cancelRefresh()
        XCTAssert(refreshable.refreshOperationQueue.operations.reduce(true, { $0 && $1.isCancelled }))
        wait(for: [updateRefreshExpectation], timeout: 1.0)
    }

    func test_addRequest() {
        let neverFinishOp = Operation()
        let op = Operation()
        op.addDependency(neverFinishOp)

        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh called")
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        XCTAssertFalse(refreshable.refreshOperationQueue.operations.contains(op))

        refreshable.addRefreshOperations([op])
        XCTAssert(refreshable.refreshOperationQueue.operations.contains(op))
        XCTAssertEqual(refreshable.refreshOperationQueue.operations.count, 1)
        wait(for: [updateRefreshExpectation], timeout: 1.0)
    }

    func test_enableRefreshing() {
        refreshable.enableRefreshing()
        XCTAssertNotNil(refreshable.refreshControl)
    }

    func test_disableRefreshing() {
        refreshable.enableRefreshing()
        refreshable.disableRefreshing()
        XCTAssertNil(refreshable.refreshControl)
    }

}

class UserDefaultsRefreshableTests: TBATestCase {

    var refreshable: MockRefreshable!

    override func setUp() {
        super.setUp()

        refreshable = MockRefreshable(userDefaults: userDefaults)
    }

    override func tearDown() {
        refreshable = nil

        super.tearDown()
    }

    func test_clearSuccessfulRefreshes() {
        XCTAssertNil(userDefaults.object(forKey: "successful_refresh_keys"))
        refreshable.markRefreshSuccessful(Calendar.current.date(byAdding: DateComponents(hour: -1), to: Date())!)
        XCTAssertNotNil(userDefaults.object(forKey: "successful_refresh_keys"))
        userDefaults.clearSuccessfulRefreshes()
        XCTAssertNil(userDefaults.object(forKey: "successful_refresh_keys"))
    }

}
