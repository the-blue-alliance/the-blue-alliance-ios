import XCTest
@testable import MyTBAKit

class MyTBAErrorTests: XCTestCase {

    func test_code() {
        let errorNoCode = MyTBAError.error(nil, "")
        XCTAssertNil(errorNoCode.code)

        let error = MyTBAError.error(210, "")
        XCTAssertEqual(error.code, 210)
    }

    func test_errorMessage() {
        let errorMessage = "Testing error message"
        let error = MyTBAError.error(nil, errorMessage)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

}

class MyTBATests: MyTBATestCase {

    func test_init() {
        let uuid = "abcd123"
        let deviceName = "My Device"
        let fcmToken = "abc"

        let mfcm = MockFCMTokenProvider(fcmToken: fcmToken)
        let midTokenProvider = MockIDTokenProvider()
        let zz = MyTBA(
            uuid: uuid,
            deviceName: deviceName,
            fcmTokenProvider: mfcm,
            idTokenProvider: midTokenProvider
        )
        XCTAssertEqual(zz.uuid, uuid)
        XCTAssertEqual(zz.deviceName, deviceName)
        XCTAssertEqual(zz.fcmToken, fcmToken)
    }

    func test_authenticationProvider_authenticated() {
        let authObserver = MockAuthObserver()
        myTBA.authenticationProvider.add(observer: authObserver)

        XCTAssertFalse(myTBA.isAuthenticated)

        let authenticatedExpectation = expectation(description: "myTBA Authenticated")
        authObserver.authenticatedExpectation = authenticatedExpectation
        myTBA.idTokenProvider.isSignedIn = true
        myTBA.notifyAuthStateChanged(isAuthenticated: true)
        wait(for: [authenticatedExpectation], timeout: 1.0)
    }

    func test_authenticationProvider_noChange() {
        let authObserver = MockAuthObserver()
        myTBA.authenticationProvider.add(observer: authObserver)

        myTBA.idTokenProvider.isSignedIn = true
        myTBA.notifyAuthStateChanged(isAuthenticated: true)

        let authenticatedExpectation = expectation(description: "myTBA Authenticated")
        authenticatedExpectation.isInverted = true
        authObserver.authenticatedExpectation = authenticatedExpectation
        myTBA.notifyAuthStateChanged(isAuthenticated: true)

        wait(for: [authenticatedExpectation], timeout: 1.0)
    }

    func test_authenticationProvider_unauthenticated() {
        let authObserver = MockAuthObserver()
        myTBA.authenticationProvider.add(observer: authObserver)

        myTBA.idTokenProvider.isSignedIn = true
        myTBA.notifyAuthStateChanged(isAuthenticated: true)

        let unauthenticatedExpectation = expectation(description: "myTBA Unauthenticated")
        authObserver.unauthenticatedExpectation = unauthenticatedExpectation
        myTBA.idTokenProvider.isSignedIn = false
        myTBA.notifyAuthStateChanged(isAuthenticated: false)

        wait(for: [unauthenticatedExpectation], timeout: 1.0)
    }

    func test_isAuthenticated() {
        XCTAssertFalse(myTBA.isAuthenticated)
        myTBA.idTokenProvider.isSignedIn = true
        XCTAssert(myTBA.isAuthenticated)
        myTBA.idTokenProvider.isSignedIn = false
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

    func test_callApi_hasBearer() async throws {
        myTBA.idTokenProvider.isSignedIn = true
        myTBA.idTokenProvider.stubbedToken = "abcd123"
        myTBA.stub(for: "favorites/list")
        _ = try await myTBA.fetchFavorites()

        guard let request = myTBA.session.lastRequest else {
            XCTFail()
            return
        }
        XCTAssertEqual(request.httpMethod, "POST")

        guard let headers = request.allHTTPHeaderFields,
            let authorizationHeader = headers["Authorization"]
        else {
            XCTFail()
            return
        }
        XCTAssertEqual(authorizationHeader, "Bearer abcd123")
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
