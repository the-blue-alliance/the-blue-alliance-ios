import XCTest
@testable import TBA

class StatusServiceOperationTestCase: TBATestCase {

    var mockStatusService: MockStatusService!
    var statusServiceOperation: MockStatusServiceOperation!

    override func setUp() {
        super.setUp()

        mockStatusService = MockStatusService(bundle: testBundle,
                                              persistentContainer: persistentContainer,
                                              retryService: RetryService(),
                                              tbaKit: tbaKit)
        statusServiceOperation = MockStatusServiceOperation(statusService: mockStatusService)
    }

    override func tearDown() {
        statusServiceOperation = nil
        mockStatusService = nil

        super.tearDown()
    }

    func test_execute() {
        let fetchExpectation = expectation(description: "fetch called")
        mockStatusService.fetchExpectation = fetchExpectation

        let setupStatusObserversExpectation = expectation(description: "setupStatusObservers called")
        mockStatusService.setupStatusObserversExpectation = setupStatusObserversExpectation

        let finishExpectation = XCTestExpectation(description: "finish called")
        statusServiceOperation.finishExpectation = finishExpectation

        statusServiceOperation.execute()

        wait(for: [finishExpectation, fetchExpectation, setupStatusObserversExpectation], timeout: 1.0)
    }

}

class MockStatusService: StatusService {

    var mockError: Error?
    var fetchExpectation: XCTestExpectation?

    var setupStatusObserversExpectation: XCTestExpectation?

    override func fetchStatus(completion: ((Error?) -> Void)?) -> URLSessionDataTask {
        fetchExpectation?.fulfill()
        completion?(mockError)
        return super.fetchStatus()
    }

    override func setupStatusObservers() {
        setupStatusObserversExpectation?.fulfill()
    }

}

class MockStatusServiceOperation: StatusServiceOperation {

    var finishExpectation: XCTestExpectation?

    override func finish() {
        finishExpectation?.fulfill()

        super.finish()
    }

}
