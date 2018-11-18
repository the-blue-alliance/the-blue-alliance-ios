import XCTest
@testable import The_Blue_Alliance

class APIErrorTests: XCTestCase {

    func test_errorMessage() {
        let errorMessage = "Testing error message"
        let error = APIError.error(errorMessage)
        XCTAssertEqual(error.localizedDescription, errorMessage)
    }

}

class TBAKitTests: XCTestCase, TBAKitMockable {
    
    var kit: TBAKit!
    var session: MockURLSession!
    
    override func setUp() {
        super.setUp()
        
        setUpTBAKitMockable()
    }
    
    override func tearDown() {
        TBAKit.clearLastModified()

        super.tearDown()
    }

    func testSingleton() {
        let kit1 = TBAKit.sharedKit
        let kit2 = TBAKit.sharedKit
        XCTAssertEqual(kit1, kit2)
    }
    
    func testAPIKey() {
        let kit1 = TBAKit.sharedKit
        TBAKit.sharedKit.apiKey = "abcd123"
        XCTAssertEqual(kit1, TBAKit.sharedKit)
    }

    func testNoAPIKey() {
        let ex = expectation(description: "no_api_key")
        
        let testKit = TBAKit()
        testKit.urlSession = session
        testKit.apiKey = nil
        
        let task = testKit.fetchStatus { (status, error) in
            XCTAssertNil(status)
            XCTAssertNotNil(error)
            
            ex.fulfill()
        }
        sendUnauthorizedStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testAPIKeyInAuthorizationHeaders() {
        let ex = expectation(description: "auth_header_api_key")
        session.resumeExpectation = ex
        
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

        wait(for: [ex], timeout: 2.0)

        session.resumeExpectation = nil
    }
    
    func testCancelTask() {
        let ex = expectation(description: "cancel_task")
        session.cancelExpectation = ex
        
        let task = kit.fetchStatus { (status, error) in
            XCTFail()
            return
        }
        task.cancel()
        
        wait(for: [ex], timeout: 2.0)

        session.cancelExpectation = nil
    }
    
    func testLastModified() {
        let setLastModifiedExpectation = expectation(description: "last_modified")
        var setLastModifiedTask: URLSessionDataTask?
        setLastModifiedTask = kit.fetchStatus { (status, error) in
            XCTAssertNotNil(status)
            XCTAssertNil(error)

            TBAKit.setLastModified(for: setLastModifiedTask!)

            setLastModifiedExpectation.fulfill()
        }
        sendSuccessStub(for: setLastModifiedTask!, headerFields: ["Last-Modified": "Sun, 11 Jun 2017 03:34:00 GMT"])
        wait(for: [setLastModifiedExpectation], timeout: 1.0)

        let setIfModifiedSinceExpectation = expectation(description: "if_modified_since")
        let setIfModifiedSinceTask = kit.fetchStatus { (status, error) in
            XCTAssertNil(status)
            XCTAssertNil(error)
            
            setIfModifiedSinceExpectation.fulfill()
        }
        sendSuccessStub(for: setIfModifiedSinceTask, with: 304)
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
        sendSuccessStub(for: setLastModifiedTask, with: 404, headerFields: ["Last-Modified": "Sun, 11 Jun 2017 03:34:00 GMT"])
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
        TBAKit.clearLastModified()

        let setLastModifiedTask = kit.fetchStatus { (status, error) in
        }

        guard let headers = setLastModifiedTask.currentRequest?.allHTTPHeaderFields else {
            XCTFail()
            return
        }
        XCTAssertNil(headers["If-Modified-Since"])
    }
}
