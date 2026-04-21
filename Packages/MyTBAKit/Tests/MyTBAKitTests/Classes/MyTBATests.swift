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

    @MainActor
    func test_authStateChanges_emitsInitialValue() async {
        mockMyTBA.idTokenProvider.isSignedIn = true

        var iterator = await myTBA.authStateChanges().makeAsyncIterator()
        let first = await iterator.next()
        XCTAssertEqual(first, true)
    }

    @MainActor
    func test_authStateChanges_emitsOnChange() async {
        var iterator = await myTBA.authStateChanges().makeAsyncIterator()
        let initial = await iterator.next()
        XCTAssertEqual(initial, false)

        mockMyTBA.idTokenProvider.isSignedIn = true
        await myTBA.notifyAuthStateChanged(isAuthenticated: true)

        let next = await iterator.next()
        XCTAssertEqual(next, true)
    }

    @MainActor
    func test_authStateChanges_noEmitOnUnchanged() async {
        mockMyTBA.idTokenProvider.isSignedIn = true
        await myTBA.notifyAuthStateChanged(isAuthenticated: true)

        var iterator = await myTBA.authStateChanges().makeAsyncIterator()
        let initial = await iterator.next()
        XCTAssertEqual(initial, true)

        // Posting the same state a second time should NOT yield another value.
        await myTBA.notifyAuthStateChanged(isAuthenticated: true)

        let raceExpectation = expectation(description: "No second emit")
        raceExpectation.isInverted = true
        let task = Task {
            _ = await iterator.next()
            raceExpectation.fulfill()
        }
        await fulfillment(of: [raceExpectation], timeout: 0.25)
        task.cancel()
    }

    @MainActor
    func test_authStateChanges_cleansUpOnCancel() async {
        let consumed = expectation(description: "Consumed initial value")
        let task = Task {
            for await _ in await myTBA.authStateChanges() {
                consumed.fulfill()
                break
            }
        }
        await fulfillment(of: [consumed], timeout: 1.0)
        task.cancel()

        // Give the termination a moment, then post a new value. Terminated
        // continuations are pruned on the next `notifyAuthStateChanged` call
        // via the YieldResult check.
        try? await Task.sleep(nanoseconds: 50_000_000)
        mockMyTBA.idTokenProvider.isSignedIn = true
        await myTBA.notifyAuthStateChanged(isAuthenticated: true)
    }

    func test_isAuthenticated() {
        XCTAssertFalse(myTBA.isAuthenticated)
        mockMyTBA.idTokenProvider.isSignedIn = true
        XCTAssert(myTBA.isAuthenticated)
        mockMyTBA.idTokenProvider.isSignedIn = false
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
        mockMyTBA.idTokenProvider.isSignedIn = true
        mockMyTBA.idTokenProvider.stubbedToken = "abcd123"
        mockMyTBA.stub(for: "favorites/list")
        _ = try await myTBA.fetchFavorites()

        guard let request = mockMyTBA.session.lastRequest else {
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
