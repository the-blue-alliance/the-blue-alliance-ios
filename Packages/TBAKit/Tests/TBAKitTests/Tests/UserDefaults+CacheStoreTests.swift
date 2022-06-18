import XCTest
@testable import TBAKit

final class TBACacheStoreTests: XCTestCase {

    var cache: TBACacheStore!
    var url: URL!

    override func setUp() {
        super.setUp()

        cache = TBACache()
        url = URL(string: "https://thebluealliance.com")!
    }

    override func tearDown() {
        cache.clear()

        super.tearDown()
    }

    func test_empty() {
        XCTAssertNil(cache.get(forURL: url))
    }

    func test_set_get() {
        let empty = cache.get(forURL: url)
        XCTAssertNil(empty)

        let response = TBACachedResponse(url: url, date: Date(), etag: "someetaghere", data: Data())
        cache.set(response, forURL: url)

        let roundTripResponse = cache.get(forURL: url)
        XCTAssertNotNil(roundTripResponse)
        XCTAssertEqual(response, roundTripResponse)
    }

    func test_clear() {
        let response = TBACachedResponse(url: url, date: Date(), etag: "someetaghere", data: Data())
        cache.set(response, forURL: url)

        let roundTripResponse = cache.get(forURL: url)
        XCTAssertNotNil(roundTripResponse)
        XCTAssertEqual(response, roundTripResponse)

        cache.clear()
        XCTAssertNil(cache.get(forURL: url))
    }

}
