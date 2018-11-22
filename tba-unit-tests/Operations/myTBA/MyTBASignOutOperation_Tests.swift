import Firebase
import XCTest
@testable import The_Blue_Alliance

class MyTBASignOutOperationTestCase: XCTestCase {

    var myTBA: MockMyTBA!
    var myTBASignOutOperation: MyTBASignOutOperation!

    override func setUp() {
        super.setUp()

        myTBA = MockMyTBA()
        myTBASignOutOperation = MyTBASignOutOperation(myTBA: myTBA, pushToken: "push_token")
    }

    override func tearDown() {
        myTBA = nil
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
        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_error() {
        let expectation = XCTestExpectation(description: "Finish called")
        myTBA.unregisterError = NSError(domain: "com.zor.zach", code: 2337, userInfo: nil)
        myTBASignOutOperation.completionBlock = { [weak myTBASignOutOperation] in
            XCTAssertNotNil(myTBASignOutOperation?.completionError)
            expectation.fulfill()
        }
        myTBASignOutOperation.execute()
        wait(for: [expectation], timeout: 1.0)
    }

}

class MockMyTBA: MyTBA {

    var unregisterError: Error?

    init() {
        super.init(uuid: "abcd123")
    }

    // https://github.com/jrose-apple/swift-evolution/blob/overridable-members-in-extensions/proposals/nnnn-overridable-members-in-extensions.md
    override func unregister(_ token: String, completion: @escaping (Error?) -> Void) -> URLSessionDataTask? {
        completion(unregisterError)
        return nil
    }

}
