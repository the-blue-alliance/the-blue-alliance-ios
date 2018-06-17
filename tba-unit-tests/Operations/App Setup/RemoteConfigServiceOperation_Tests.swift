import XCTest
import FirebaseRemoteConfig
@testable import The_Blue_Alliance

class RemoteConfigServiceOperationTestCase: XCTestCase {

    var remoteConfigService: MockRemoteConfigService!
    var remoteConfigServiceOperation: MockRemoteConfigServiceOperation!

    override func setUp() {
        super.setUp()

        remoteConfigService = MockRemoteConfigService(remoteConfig: RemoteConfig.remoteConfig(),
                                                      retryService: MockRetryService())
        remoteConfigServiceOperation = MockRemoteConfigServiceOperation(remoteConfigService: remoteConfigService)
    }

    override func tearDown() {
        remoteConfigService = nil
        remoteConfigServiceOperation = nil

        super.tearDown()
    }

    func test_execute() {
        assertCallsFinish()
    }

    func test_execute_error() {
        remoteConfigService.mockError = NSError(domain: "com.zor.zach", code: 2337, userInfo: nil)
        assertCallsFinish()
    }

    func assertCallsFinish() {
        let expectation = XCTestExpectation(description: "Finish called")
        remoteConfigServiceOperation.finishExpectation = expectation
        remoteConfigServiceOperation.execute()
        wait(for: [expectation], timeout: 1.0)
    }

    func test_retry_intervalPositive() {
        XCTAssertGreaterThan(remoteConfigService.retryInterval, 0)
    }

    func test_retry_callsFetchRemoteConfig() {
        let expectation = XCTestExpectation(description: "fetchRemoteConfig called")
        remoteConfigService.fetchRemoteConfigExpectation = expectation
        remoteConfigService.retry()
        wait(for: [expectation], timeout: 1.0)
    }

}

class MockRetryService: RetryService {}

class MockRemoteConfigService: RemoteConfigService {

    var mockError: Error?
    var fetchRemoteConfigExpectation: XCTestExpectation?

    override func fetchRemoteConfig(completion: ((_ error: Error?) -> Void)? = nil) {
        fetchRemoteConfigExpectation?.fulfill()

        completion?(mockError)
    }

}

class MockRemoteConfigServiceOperation: RemoteConfigServiceOperation {

    var finishExpectation: XCTestExpectation?

    override func finish() {
        finishExpectation?.fulfill()

        super.finish()
    }

}
