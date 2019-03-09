import XCTest
@testable import TBA

class MyTBAErrorTests: XCTestCase {

    func test_errorMessage() {
        let errorMessage = "Testing error message"
        let error = MyTBAError.error(errorMessage)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

}

class MyTBATests: MyTBATestCase {

    func test_init() {
        let uuid = "abcd123"
        let deviceName = "My Device"

        let zz = MyTBA(uuid: uuid, deviceName: deviceName)
        XCTAssertEqual(zz.uuid, uuid)
        XCTAssertEqual(zz.deviceName, deviceName)
    }

    func test_authenticationProvider_authenticated() {
        let authObserver = MockAuthObserver()
        myTBA.authenticationProvider.add(observer: authObserver)

        XCTAssertNil(myTBA.authToken)

        let authenticatedExpectation = expectation(description: "myTBA Authenticated")
        authObserver.authenticatedExpectation = authenticatedExpectation
        myTBA.authToken = "abcd123"
        wait(for: [authenticatedExpectation], timeout: 1.0)
    }

    func test_authenticationProvider_noChange() {
        let authObserver = MockAuthObserver()
        myTBA.authenticationProvider.add(observer: authObserver)

        XCTAssertNil(myTBA.authToken)
        myTBA.authToken = "abcd123"

        let authenticatedExpectation = expectation(description: "myTBA Authenticated")
        authenticatedExpectation.isInverted = true
        authObserver.authenticatedExpectation = authenticatedExpectation
        myTBA.authToken = "abcd123"

        wait(for: [authenticatedExpectation], timeout: 1.0)
    }

    func test_authenticationProvider_changed() {
        let authObserver = MockAuthObserver()
        myTBA.authenticationProvider.add(observer: authObserver)

        XCTAssertNil(myTBA.authToken)
        myTBA.authToken = "abcd123"

        let authenticatedExpectation = expectation(description: "myTBA Authenticated")
        authObserver.authenticatedExpectation = authenticatedExpectation
        myTBA.authToken = "321dcba"

        wait(for: [authenticatedExpectation], timeout: 1.0)
    }

    func test_authenticationProvider_unauthenticated() {
        let authObserver = MockAuthObserver()
        myTBA.authenticationProvider.add(observer: authObserver)

        XCTAssertNil(myTBA.authToken)
        myTBA.authToken = "abcd123"

        let unauthenticatedExpectation = expectation(description: "myTBA Unauthenticated")
        authObserver.unauthenticatedExpectation = unauthenticatedExpectation
        myTBA.authToken = nil

        wait(for: [unauthenticatedExpectation], timeout: 1.0)
    }

    func test_isAuthenticated() {
        XCTAssertFalse(myTBA.isAuthenticated)
        myTBA.authToken = "abcd123"
        XCTAssert(myTBA.isAuthenticated)
        myTBA.authToken = nil
        XCTAssertFalse(myTBA.isAuthenticated)
    }

    func test_jsonEncoder() {
        let jsonEncoder = MyTBA.jsonEncoder
        XCTAssertNotNil(jsonEncoder)
    }

    func test_jsonDecoder() {
        let jsonDecoder = MyTBA.jsonDecoder
        XCTAssertNotNil(jsonDecoder)
    }

    func test_callApi_hasBearer() {
        myTBA.authToken = "abcd123"
        let task = myTBA.callApi(method: "test") { (registerResponse: MyTBABaseResponse?, error: Error?) in
            // NOP
        }
        guard let request = task.currentRequest else {
            XCTFail()
            return
        }
        XCTAssertEqual(request.httpMethod, "POST")

        guard let headers = request.allHTTPHeaderFields else {
            XCTFail()
            return
        }
        guard let authorizationHeader = headers["Authorization"] else {
            XCTFail()
            return
        }
        XCTAssert(authorizationHeader.contains("Bearer"))
    }

}

private class MockAuthObserver: MyTBAAuthenticationObservable {

    var authenticatedExpectation: XCTestExpectation?
    var unauthenticatedExpectation: XCTestExpectation?

    func authenticated() {
        authenticatedExpectation?.fulfill()
    }

    func unauthenticated() {
        unauthenticatedExpectation?.fulfill()
    }
}
