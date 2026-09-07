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

    func test_jsonEncoder() {
        let jsonEncoder = MyTBA.jsonEncoder
        XCTAssertNotNil(jsonEncoder)
    }

    func test_jsonDecoder() {
        let jsonDecoder = MyTBA.jsonDecoder
        XCTAssertNotNil(jsonDecoder)
    }

    func test_callApi_noBearerWhenSignedOut() async throws {
        myTBA.idTokenProvider.isSignedIn = false
        myTBA.stub(for: "favorites/list")
        _ = try await myTBA.fetchFavorites()

        let request = try XCTUnwrap(myTBA.session.lastRequest)
        XCTAssertNil(request.allHTTPHeaderFields?["Authorization"])
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
