import XCTest
@testable import TBAOperation

class TBAOperationTestCase: XCTestCase {

    var operation: MockOperation!

    override func setUp() {
        super.setUp()

        operation = MockOperation()
    }

    override func tearDown() {
        operation = nil

        super.tearDown()
    }

    func test_executing_kvo() {
        let kvoExpectation = XCTKVOExpectation(keyPath: #keyPath(TBAOperation.isExecuting), object: operation)

        operation._executing = true

        wait(for: [kvoExpectation], timeout: 1.0)
    }

    func test_finished_kvo() {
        let kvoExpectation = XCTKVOExpectation(keyPath: #keyPath(TBAOperation.isFinished), object: operation)

        operation._finished = true

        wait(for: [kvoExpectation], timeout: 1.0)
    }

    func test_cancelled_kvo() {
        let kvoExpectation = XCTKVOExpectation(keyPath: #keyPath(TBAOperation.isCancelled), object: operation)

        operation._cancelled = true

        wait(for: [kvoExpectation], timeout: 1.0)
    }

    func test_execute() {
        let expectation = XCTestExpectation(description: "Execute called")
        operation.executeExpectation = expectation

        operation.start()

        wait(for: [expectation], timeout: 1.0)
        XCTAssert(operation.isExecuting)
    }

    func test_cancelled() {
        let expectation = XCTestExpectation(description: "Execute not called")
        expectation.isInverted = true
        operation.executeExpectation = expectation

        operation.cancel()
        operation.start()

        wait(for: [expectation], timeout: 1.0)
        operation.assertIsFinished()
    }

    func test_cancelled_callsFinish() {
        let expectation = XCTestExpectation(description: "Finish called")
        operation.finishExpectation = expectation

        operation.cancel()
        operation.start()

        wait(for: [expectation], timeout: 1.0)
    }

    func test_finish() {
        operation.finish()
        operation.assertIsFinished()
    }

}
