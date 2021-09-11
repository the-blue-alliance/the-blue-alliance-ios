import TBATestingMocks
import XCTest
@testable import TBAKit

class APIErrorTests: XCTestCase {

    func test_errorMessage() {
        let errorMessage = "Testing error message"
        let error = APIError.error(errorMessage)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

}

class TBAKitTests: TBAKitTestCase {

    func test_init() {
        let ud = UserDefaults(suiteName: "dummy")!
        let apiKey = "abcdefg"
        let testKit = TBAKit(apiKey: apiKey, userDefaults: ud)
        XCTAssertEqual(testKit.apiKey, apiKey)
        XCTAssertEqual(testKit.userDefaults, ud)
        XCTAssertNotNil(testKit.sessionProvider)
    }

    func test_init_session() {
        let ud = UserDefaults(suiteName: "dummy")!
        let apiKey = "abcdefg"
        let testKit = TBAKit(apiKey: apiKey, userDefaults: ud)
        XCTAssertEqual(testKit.apiKey, apiKey)
        XCTAssertEqual(testKit.userDefaults, ud)
    }

    func testAPIKeyInAuthorizationHeaders() {
        let ex = expectation(description: "auth_header_api_key")
        kit.session.resumeExpectation = ex

        let operation = kit.fetchStatus { (result, notModified) in
            XCTFail() // shouldn't be called
        }
        let operationQueue = OperationQueue()
        operationQueue.addOperation(operation)

        guard let headers = operation.task.currentRequest?.allHTTPHeaderFields else {
            XCTFail()
            return
        }
        guard let apiKeyHeader = headers["X-TBA-Auth-Key"] else {
            XCTFail()
            return
        }
        XCTAssertEqual(apiKeyHeader, "abcd123")

        guard let acceptEncoding = headers["Accept-Encoding"] else {
            XCTFail()
            return
        }
        XCTAssertEqual(acceptEncoding, "gzip")

        wait(for: [ex], timeout: 2.0)

        kit.session.resumeExpectation = nil
    }

    func testCancelTask() {
        let ex = expectation(description: "cancel_task")
        kit.session.cancelExpectation = ex

        let operation = kit.fetchStatus { (result, notModified) in
            XCTFail()
            return
        }
        operation.cancel()

        wait(for: [ex], timeout: 2.0)

        kit.session.cancelExpectation = nil
    }

    func testStoreCacheHeaders() {
        let storeCacheHeadersExpectation = expectation(description: "store_cache_headers")
        var storeCacheHeadersOperation: TBAKitOperation?
        storeCacheHeadersOperation = kit.fetchStatus { (result, notModified) in
            _ = try! result.get()
            XCTAssertFalse(notModified)

            self.kit.storeCacheHeaders(storeCacheHeadersOperation!)

            storeCacheHeadersExpectation.fulfill()
        }
        kit.sendSuccessStub(for: storeCacheHeadersOperation!)
        wait(for: [storeCacheHeadersExpectation], timeout: 1.0)

        let notModifiedExpectation = expectation(description: "not_modified")
        let notModifiedOperation = kit.fetchStatus { (result, notModified) in
            let status = try! result.get()
            XCTAssert(notModified)
            XCTAssertNil(status)

            notModifiedExpectation.fulfill()
        }
        kit.sendSuccessStub(for: notModifiedOperation, with: 304)
        wait(for: [notModifiedExpectation], timeout: 1.0)

        guard let headers = notModifiedOperation.task.currentRequest?.allHTTPHeaderFields else {
            XCTFail()
            return
        }

        guard let ifModifiedSinceHeader = headers["If-Modified-Since"] else {
            XCTFail()
            return
        }
        XCTAssertEqual(ifModifiedSinceHeader, "Sun, 11 Jun 2017 03:34:00 GMT")

        guard let etagHeader = headers["If-None-Match"] else {
            XCTFail()
            return
        }
        XCTAssertEqual(etagHeader, "W/\"1ea6e1a87aafbbeeb6a89b31cf4fb84c\"")
    }

    func testDoesNotStoreErrorLastModified() {
        let setCacheHeadersExpectation = expectation(description: "set_cache_headers")
        let setCacheHeadersOperation = kit.fetchStatus { (result, notModified) in
            _ = try! result.get()
            XCTAssertFalse(notModified)

            setCacheHeadersExpectation.fulfill()
        }
        kit.sendSuccessStub(for: setCacheHeadersOperation, with: 404)
        wait(for: [setCacheHeadersExpectation], timeout: 1.0)

        _ = kit.fetchStatus { (result, notModified) in
            XCTFail()
        }
        guard let headers = setCacheHeadersOperation.task.currentRequest?.allHTTPHeaderFields else {
            XCTFail()
            return
        }
        XCTAssertNil(headers["If-Modified-Since"])
        XCTAssertNil(headers["If-None-Match"])
    }

    func testClearCacheHeaders() {
        kit.clearCacheHeaders()

        let storeCacheHeadersOperation = kit.fetchStatus { (result, notModified) in
            XCTFail()
        }

        guard let headers = storeCacheHeadersOperation.task.currentRequest?.allHTTPHeaderFields else {
            XCTFail()
            return
        }
        XCTAssertNil(headers["If-Modified-Since"])
        XCTAssertNil(headers["If-None-Match"])
    }

}
