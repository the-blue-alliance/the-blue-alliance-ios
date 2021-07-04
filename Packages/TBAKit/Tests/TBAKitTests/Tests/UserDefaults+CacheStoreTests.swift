import XCTest
@testable import TBAKit

final class UserDefaultsCacheStoreTests: XCTestCase {

    var userDefaults: UserDefaults!
    var url: URL!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "UserDefaultsCacheStoreTests")
        url = URL(string: "https://thebluealliance.com")!
    }

    override func tearDown() {
        for key in userDefaults.dictionaryRepresentation().keys {
            userDefaults.removeObject(forKey: key)
        }

        super.tearDown()
    }

    func test_cache_empty() {
        XCTAssertNil(userDefaults.get(forURL: url))
    }

    func test_cache_notData() {
        // Manually insert garbage data in to the cache
        userDefaults.set([url.absoluteString: "efg"], forKey: kCacheKey)
        XCTAssertNil(userDefaults.get(forURL: url))
    }

    func test_cache_badData() {
        // Manually insert garbage data in to the cache
        userDefaults.set([url.absoluteString: Data()], forKey: kCacheKey)
        XCTAssertNil(userDefaults.get(forURL: url))
    }

    func test_setCache() {
        let cache = CachedResponse(url: url, lastModified: "Last Modified", etag: "someetaghere", data: Data())
        userDefaults.set(cache, forURL: url)

        let roundTripCache = userDefaults.get(forURL: url)
        XCTAssertNotNil(roundTripCache)
        XCTAssertEqual(cache, roundTripCache)
    }

    func test_setCache_internal() {
        let cache = CachedResponse(url: url, lastModified: "Last Modified", etag: "someetaghere", data: Data())
        userDefaults.set(cache, forURL: url)

        let cacheObject = userDefaults.object(forKey: kCacheKey)
        XCTAssertNotNil(cacheObject)

        guard let cacheDictionary = cacheObject as? CacheDictionary else {
            XCTFail("cacheDictionary expected to be CacheDictionary")
            return
        }
        XCTAssertEqual(Array(cacheDictionary.keys), [url.absoluteString])

        let value = cacheDictionary[url.absoluteString]
        XCTAssertNotNil(value)
    }

    func test_clearCache() {
        let cache = CachedResponse(url: url, lastModified: "Last Modified", etag: "someetaghere", data: Data())
        userDefaults.set(cache, forURL: url)

        let roundTripCache = userDefaults.get(forURL: url)
        XCTAssertNotNil(roundTripCache)
        XCTAssertEqual(cache, roundTripCache)

        userDefaults.clear()
        XCTAssertNil(userDefaults.get(forURL: url))
    }

}
