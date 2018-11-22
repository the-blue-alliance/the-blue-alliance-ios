import XCTest
@testable import The_Blue_Alliance

class MyTBAErrorTests: XCTestCase {

    func test_errorMessage() {
        let errorMessage = "Testing error message"
        let error = MyTBAError.error(errorMessage)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

    class MyTBATests: XCTestCase {
        func test_init() {
            let uuid = "abcd123"

            let myTBA = MyTBA(uuid: uuid)
            XCTAssertEqual(myTBA.uuid, uuid)
        }
    }

}
