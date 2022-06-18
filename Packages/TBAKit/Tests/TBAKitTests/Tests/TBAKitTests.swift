import XCTest
@testable import TBAKit

final class TBAKitTests: XCTestCase {

    func test_init_default() {
        let apiKey = "apikey"
        let kit = TBAKit(apiKey: "apikey")

        XCTAssertEqual(kit.apiKey, apiKey)

        guard let session = kit.session as? URLSession else {
            XCTFail("TBAKit.session expected to be a URLSession")
            return
        }
        XCTAssertEqual(session.configuration, URLSessionConfiguration.default)
        XCTAssertNil(kit.cacheStore)
    }

    func test_init() {
        let apiKey = "apikey"
        let session = URLSession(configuration: .ephemeral)
        let cacheStore = TBACache()
        let kit = TBAKit(apiKey: apiKey, session: session, cacheStore: cacheStore)

        XCTAssertEqual(kit.apiKey, apiKey)
        XCTAssertEqual(kit.session as? URLSession, session)
        XCTAssertNotNil(kit.cacheStore)
    }

    func test_clearCache() {
        let cache = TBACache()
        let kit = TBAKit(apiKey: "apikey", cacheStore: cache)

        let url = URL(string: "https://thebluealliance.com")!
        cache.set(TBACachedResponse(url: url, date: Date(), etag: "someetag", data: Data()), forURL: url)
        XCTAssertNotNil(cache.get(forURL: url))

        kit.clearCache()
        XCTAssertNil(cache.get(forURL: url))
    }

}
