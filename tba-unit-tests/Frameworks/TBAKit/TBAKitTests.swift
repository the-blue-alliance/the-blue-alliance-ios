import XCTest
@testable import TBA

class APIErrorTests: XCTestCase {

    func test_errorMessage() {
        let errorMessage = "Testing error message"
        let error = APIError.error(errorMessage)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

}

class TBAKitTests: TBAKitTestCase {
    
    func testAPIKeyInAuthorizationHeaders() {
        let ex = expectation(description: "auth_header_api_key")
        kit.session.resumeExpectation = ex
        
        let task = kit.fetchStatus { (status, error) in
            XCTFail() // shouldn't be called
        }
        
        guard let headers = task.currentRequest?.allHTTPHeaderFields else {
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
        
        let task = kit.fetchStatus { (status, error) in
            XCTFail()
            return
        }
        task.cancel()
        
        wait(for: [ex], timeout: 2.0)

        kit.session.cancelExpectation = nil
    }
    
    func testLastModified() {
        let setLastModifiedExpectation = expectation(description: "last_modified")
        var setLastModifiedTask: URLSessionDataTask?
        setLastModifiedTask = kit.fetchStatus { (status, error) in
            XCTAssertNotNil(status)
            XCTAssertNil(error)

            self.kit.setLastModified(setLastModifiedTask!)

            setLastModifiedExpectation.fulfill()
        }
        kit.sendSuccessStub(for: setLastModifiedTask!)
        wait(for: [setLastModifiedExpectation], timeout: 1.0)

        let setIfModifiedSinceExpectation = expectation(description: "if_modified_since")
        let setIfModifiedSinceTask = kit.fetchStatus { (status, error) in
            XCTAssertNil(status)
            XCTAssertNil(error)
            
            setIfModifiedSinceExpectation.fulfill()
        }
        kit.sendSuccessStub(for: setIfModifiedSinceTask, with: 304)
        wait(for: [setIfModifiedSinceExpectation], timeout: 1.0)

        guard let headers = setIfModifiedSinceTask.currentRequest?.allHTTPHeaderFields else {
            XCTFail()
            return
        }
        guard let ifModifiedSinceHeader = headers["If-Modified-Since"] else {
            XCTFail()
            return
        }
        XCTAssertEqual(ifModifiedSinceHeader, "Sun, 11 Jun 2017 03:34:00 GMT")
    }

    func testDoesNotStoreErrorLastModified() {
        let setLastModifiedExpectation = expectation(description: "last_modified")
        let setLastModifiedTask = kit.fetchStatus { (status, error) in
            XCTAssertNotNil(status)
            XCTAssertNil(error)

            setLastModifiedExpectation.fulfill()
        }
        kit.sendSuccessStub(for: setLastModifiedTask, with: 404)
        wait(for: [setLastModifiedExpectation], timeout: 1.0)

        let setIfModifiedSinceTask = kit.fetchStatus { (status, error) in
        }
        guard let headers = setIfModifiedSinceTask.currentRequest?.allHTTPHeaderFields else {
            XCTFail()
            return
        }
        XCTAssertNil(headers["If-Modified-Since"])
    }

    func testClearLastModified() {
        kit.clearLastModified()

        let setLastModifiedTask = kit.fetchStatus { (status, error) in
        }

        guard let headers = setLastModifiedTask.currentRequest?.allHTTPHeaderFields else {
            XCTFail()
            return
        }
        XCTAssertNil(headers["If-Modified-Since"])
    }

}
