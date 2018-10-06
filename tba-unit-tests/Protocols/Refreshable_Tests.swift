import XCTest
@testable import The_Blue_Alliance

class MockRefreshable: Refreshable {

    // MARK: - Mock Expectations

    var updateRefreshExpectation: XCTestExpectation?

    var noDataReloadExpectation: XCTestExpectation?

    var mockAutomaticRefreshInterval: DateComponents?

    var mockAutomaticRefreshEndDate: Date?

    // MARK: - Protocol

    var requests: [URLSessionDataTask] = []

    var refreshControl: UIRefreshControl?

    var refreshView: UIScrollView {
        return UIScrollView()
    }

    var refreshKey: String = ""

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

    func noDataReload() {
        noDataReloadExpectation?.fulfill()
    }

    func updateRefresh() {
        updateRefreshExpectation?.fulfill()
    }

}

class Refreshable_TestCase: XCTestCase {

    var refreshable: MockRefreshable!

    override func setUp() {
        super.setUp()

        refreshable = MockRefreshable()
    }

    override func tearDown() {
        refreshable = nil

        super.tearDown()
    }

    func test_shouldRefresh_isRefreshing() {
        refreshable.isDataSourceEmpty = true
        refreshable.requests.append(URLSessionDataTask())
        XCTAssertFalse(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_hasDataBeenRefreshed() {
        refreshable.lastRefresh = nil
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_isDataSourceEmpty() {
        refreshable.lastRefresh = Date()
        refreshable.isDataSourceEmpty = true
        XCTAssert(refreshable.shouldRefresh())

        addTeardownBlock {
            self.refreshable.lastRefresh = nil
        }
    }

    func test_shouldRefresh_dataNotStale() {
        refreshable.lastRefresh = Date()
        refreshable.mockAutomaticRefreshInterval = DateComponents(hour: 1)
        XCTAssertFalse(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_noEndDate() {
        refreshable.lastRefresh = Calendar.current.date(byAdding: DateComponents(hour: -1, minute: -1), to: Date())
        refreshable.mockAutomaticRefreshInterval = DateComponents(hour: 1)
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_beforeEndDate() {
        refreshable.lastRefresh = Calendar.current.date(byAdding: DateComponents(hour: -1, minute: -1), to: Date())
        refreshable.mockAutomaticRefreshInterval = DateComponents(hour: 1)
        refreshable.mockAutomaticRefreshEndDate = Calendar.current.date(byAdding: DateComponents(hour: 1), to: Date())
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_afterEndDate() {
        refreshable.lastRefresh = Calendar.current.date(byAdding: DateComponents(hour: -1, minute: -1), to: Date())
        refreshable.mockAutomaticRefreshInterval = DateComponents(hour: 1)
        refreshable.mockAutomaticRefreshEndDate = Calendar.current.date(byAdding: DateComponents(hour: -1), to: Date())
        XCTAssert(refreshable.shouldRefresh())
    }

    func test_shouldRefresh_afterEndDate_lastRefreshBeforeEndDate() {
        refreshable.lastRefresh = Calendar.current.date(byAdding: DateComponents(hour: -1), to: Date())
        refreshable.mockAutomaticRefreshInterval = DateComponents(minute: 30)
        refreshable.mockAutomaticRefreshEndDate = Calendar.current.date(byAdding: DateComponents(hour: -1, minute: -1), to: Date())
        XCTAssertFalse(refreshable.shouldRefresh())
    }

    func test_lastRefresh() {
        let testRefreshKey = "test_refresh_key"
        refreshable.refreshKey = testRefreshKey

        XCTAssertNil(refreshable.lastRefresh)

        let now = Date()
        refreshable.lastRefresh = now
        XCTAssertEqual(refreshable.lastRefresh, now)

        addTeardownBlock {
            self.refreshable.lastRefresh = nil
        }
    }

    func test_markRefreshSuccessful() {
        let testRefreshKey = "test_refresh_key"
        refreshable.refreshKey = testRefreshKey

        XCTAssertNil(refreshable.lastRefresh)

        refreshable.markRefreshSuccessful()
        XCTAssertNotNil(refreshable.lastRefresh)

        addTeardownBlock {
            self.refreshable.lastRefresh = nil
        }
    }

    func test_isRefreshing() {
        XCTAssertFalse(refreshable.isRefreshing)
        refreshable.requests.append(URLSessionDataTask())
        XCTAssert(refreshable.isRefreshing)
    }

    func test_cancelRefresh_noRequests() {
        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh not called")
        updateRefreshExpectation.isInverted = true
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        XCTAssert(refreshable.requests.isEmpty)

        refreshable.cancelRefresh()
        wait(for: [updateRefreshExpectation], timeout: 1.0)
    }

    func test_cancelRefresh() {
        let request = URLSession.shared.dataTask(with: URL(string: "https://www.thebluealliance.com/")!)
        refreshable.requests.append(request)

        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh called")
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        XCTAssertFalse(refreshable.requests.isEmpty)

        refreshable.cancelRefresh()
        XCTAssert(refreshable.requests.isEmpty)
        wait(for: [updateRefreshExpectation], timeout: 1.0)
    }

    func test_addRequest_ignoreDuplicates() {
        let request = URLSessionDataTask()
        refreshable.requests.append(request)

        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh not called")
        updateRefreshExpectation.isInverted = true
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        XCTAssert(refreshable.requests.contains(request))

        refreshable.addRequest(request: request)
        XCTAssert(refreshable.requests.contains(request))
        wait(for: [updateRefreshExpectation], timeout: 1.0)
    }

    func test_addRequest() {
        let request = URLSessionDataTask()

        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh called")
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        XCTAssertFalse(refreshable.requests.contains(request))

        refreshable.addRequest(request: request)
        XCTAssert(refreshable.requests.contains(request))
        wait(for: [updateRefreshExpectation], timeout: 1.0)
    }

    func test_removeRequest_ignoreNonexistant() {
        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh not called")
        updateRefreshExpectation.isInverted = true
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        let noDataReloadExpectation = XCTestExpectation(description: "noDataReload not called")
        noDataReloadExpectation.isInverted = true
        refreshable.noDataReloadExpectation = noDataReloadExpectation

        refreshable.removeRequest(request: URLSessionDataTask())
        XCTAssert(refreshable.requests.isEmpty)
        wait(for: [updateRefreshExpectation, noDataReloadExpectation], timeout: 1.0)
    }

    func test_removeRequest() {
        let request = URLSessionDataTask()
        refreshable.requests.append(request)

        let updateRefreshExpectation = XCTestExpectation(description: "updateRefresh called")
        refreshable.updateRefreshExpectation = updateRefreshExpectation

        let noDataReloadExpectation = XCTestExpectation(description: "noDataReload called")
        refreshable.noDataReloadExpectation = noDataReloadExpectation

        XCTAssert(refreshable.requests.contains(request))

        refreshable.removeRequest(request: request)
        XCTAssertFalse(refreshable.requests.contains(request))
        wait(for: [updateRefreshExpectation, noDataReloadExpectation], timeout: 1.0)
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
