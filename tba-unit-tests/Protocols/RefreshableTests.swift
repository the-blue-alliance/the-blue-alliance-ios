import XCTest
@testable import TBA

class MockRefreshable: Refreshable {

    var userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: - Mock Expectations

    var updateRefreshExpectation: XCTestExpectation?

    var noDataReloadExpectation: XCTestExpectation?

    var mockRefreshKey: String?

    var mockAutomaticRefreshInterval: DateComponents?

    var mockAutomaticRefreshEndDate: Date?

    // MARK: - Protocol

    var requests: [URLSessionDataTask] = []

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
        refreshable.requests.append(URLSessionDataTask())
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
