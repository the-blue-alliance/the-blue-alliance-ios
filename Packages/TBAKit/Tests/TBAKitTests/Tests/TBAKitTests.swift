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
        let cacheStore = UserDefaults(suiteName: "TBAKitTests")
        let kit = TBAKit(apiKey: apiKey, session: session, cacheStore: cacheStore)

        XCTAssertEqual(kit.apiKey, apiKey)
        guard let tbaKitSession = kit.session as? URLSession else {
            XCTFail("TBAKit.session expected to be a URLSession")
            return
        }
        XCTAssertEqual(tbaKitSession, session)
        guard let kitCacheStore = kit.cacheStore as? UserDefaults else {
            XCTFail("TBAKit cacheStore expected to be an instance of UserDefaults")
            return
        }
        XCTAssertEqual(kitCacheStore, cacheStore)
    }

    func test_clearCache() {
        let cacheStore = UserDefaults(suiteName: "TBAKitTests")
        let kit = TBAKit(apiKey: "apikey", cacheStore: cacheStore)

        let url = URL(string: "https://thebluealliance.com")!
        cacheStore?.set(CachedResponse(url: url, lastModified: "Last Modified", etag: "someetag", data: Data()), forURL: url)
        XCTAssertNotNil(cacheStore?.get(forURL: url))

        kit.clearCache()
        XCTAssertNil(cacheStore?.get(forURL: url))
    }

}
