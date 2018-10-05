import Foundation
import XCTest
@testable import The_Blue_Alliance

class MyTBAError_TestCase: XCTestCase {

    func test_errorMessage() {
        let errorMessage = "Testing error message"
        let error = MyTBAError.error(errorMessage)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

}
