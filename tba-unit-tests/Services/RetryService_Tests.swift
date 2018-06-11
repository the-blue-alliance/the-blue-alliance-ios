import XCTest
@testable import The_Blue_Alliance

class RetryService_Tests: XCTestCase {

    func test_init() {
        XCTAssertNotNil(RetryService())
    }

}

class Retryable_Tests: XCTestCase {

    var mockRetryable: MockRetryable!

    override func setUp() {
        super.setUp()

        mockRetryable = MockRetryable()
    }

    override func tearDown() {
        mockRetryable = nil

        super.tearDown()
    }

    func test_isRetryRegistered() {
        mockRetryable.registerRetryable()
        XCTAssert(mockRetryable.retryService.isRetryRegistered)
        mockRetryable.unregisterRetryable()
        XCTAssertFalse(mockRetryable.retryService.isRetryRegistered)
    }

    func test_registerRetryable() {
        XCTAssertNoThrow(mockRetryable.registerRetryable())
    }

    func test_registerRetryable_initiallyRetry() {
        let expectation = XCTestExpectation(description: "Retry timer fires")
        mockRetryable.retryExpectation = expectation

        mockRetryable.registerRetryable(initiallyRetry: true)
        wait(for: [expectation], timeout: mockRetryable.retryInterval - 1)
    }

    func test_registerRetryable_initiallyRetryFalse() {
        let expectation = XCTestExpectation(description: "Retry timer fires")
        expectation.isInverted = true
        mockRetryable.retryExpectation = expectation

        mockRetryable.registerRetryable()
        wait(for: [expectation], timeout: mockRetryable.retryInterval - 1)
    }

    func unregisterRetryable() {
        let expectation = XCTestExpectation(description: "Retry timer fires")
        expectation.isInverted = true
        mockRetryable.retryExpectation = expectation

        mockRetryable.registerRetryable()
        mockRetryable.unregisterRetryable()
        wait(for: [expectation], timeout: mockRetryable.retryInterval)
    }

    func test_unregisterRetryable_nil() {
        XCTAssertNoThrow(mockRetryable.unregisterRetryable())
    }

    func test_unregister_onProperRunLoop() {
        let noRetryExpectation = XCTestExpectation(description: "Retry timer doesn't fires")
        noRetryExpectation.isInverted = true
        mockRetryable.retryExpectation = noRetryExpectation

        let registerExpectation = XCTestExpectation(description: "Register retry on utility thread")
        DispatchQueue.global(qos: .utility).async {
            self.mockRetryable.registerRetryable()
            registerExpectation.fulfill()
        }

        let unregisterExpectation = XCTestExpectation(description: "Unregister retry on background thread")
        DispatchQueue.global(qos: .default).async {
            self.mockRetryable.unregisterRetryable()
            unregisterExpectation.fulfill()
        }

        wait(for: [registerExpectation, unregisterExpectation, noRetryExpectation], timeout: mockRetryable.retryInterval)
    }

}

class MockRetryable: Retryable {
    var retryService = RetryService()
    var retryInterval: TimeInterval {
        return 2
    }
    var retryExpectation: XCTestExpectation?

    func retry() {
        retryExpectation?.fulfill()
    }

}
