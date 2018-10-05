import Foundation
import XCTest
@testable import The_Blue_Alliance

class BackgroundFetchError_TestCase: XCTestCase {

    func test_errorMessage() {
        let errorMessage = "Testing error message"
        let error = BackgroundFetchError.message(errorMessage)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

    func test_error() {
        let errorMessage = "Testing error message"
        let nserror = NSError(domain: "com.the-blue-alliance.testing", code: 7332, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        let error = BackgroundFetchError.error(nserror)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

}
