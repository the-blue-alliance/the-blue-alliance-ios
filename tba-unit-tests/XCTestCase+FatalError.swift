import XCTest
@testable import The_Blue_Alliance

extension XCTestCase {

    func expectFatalError(_ expectedMessage: String, testcase: @escaping () -> Void) {
        let expectation = self.expectation(description: "expectingFatalError")
        var assertionMessage: String? = nil

        // override fatalError. This will pause forever when fatalError is called.
        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            unreachable()
        }

        // act, perform on separate thead because a call to fatalError pauses forever
        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)

        waitForExpectations(timeout: 0.1) { _ in
            XCTAssertEqual(assertionMessage, expectedMessage)
            FatalErrorUtil.restoreFatalError()
        }
    }
}
