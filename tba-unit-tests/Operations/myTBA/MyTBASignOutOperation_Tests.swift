import Firebase
import XCTest
@testable import TBA

class MyTBASignOutOperationTestCase: MyTBATestCase {

    var myTBASignOutOperation: MyTBASignOutOperation!

    override func setUp() {
        super.setUp()

        myTBASignOutOperation = MyTBASignOutOperation(myTBA: myTBA, pushToken: "push_token")
    }

    override func tearDown() {
        myTBASignOutOperation = nil

        super.tearDown()
    }

    func test_execute() {
        let expectation = XCTestExpectation(description: "Finish called")
        myTBASignOutOperation.completionBlock = { [weak myTBASignOutOperation] in
            XCTAssertNil(myTBASignOutOperation?.completionError)
            expectation.fulfill()
        }
        myTBASignOutOperation.execute()

        guard let task = myTBASignOutOperation.unregisterTask else {
            XCTFail()
            return
        }
        myTBA.sendStub(for: task)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_error() {
        let expectation = XCTestExpectation(description: "Finish called")
        myTBASignOutOperation.completionBlock = { [weak myTBASignOutOperation] in
            XCTAssertNotNil(myTBASignOutOperation?.completionError)
            expectation.fulfill()
        }
        myTBASignOutOperation.execute()

        guard let task = myTBASignOutOperation.unregisterTask else {
            XCTFail()
            return
        }
        myTBA.sendStub(for: task, code: 401)

        wait(for: [expectation], timeout: 1.0)
    }

}
