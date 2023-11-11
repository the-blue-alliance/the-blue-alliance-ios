import Foundation
import TBAOperation
import XCTest

public class MockOperation: TBAOperation {

    public var executeExpectation: XCTestExpectation?
    public var finishExpectation: XCTestExpectation?
    public var cancelExpectation: XCTestExpectation?

    public override func execute() {
        executeExpectation?.fulfill()
    }

    public override func finish() {
        super.finish()

        finishExpectation?.fulfill()
    }

    public override func cancel() {
        super.cancel()

        cancelExpectation?.fulfill()
    }

    public func assertIsFinished() {
        XCTAssertFalse(isExecuting)
        XCTAssert(isFinished)
    }

}
