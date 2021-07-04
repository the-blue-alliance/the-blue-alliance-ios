import Foundation

private struct APIConstants {
    static let baseURL = URL(string: "https://www.thebluealliance.com/api/v3/")!
}

public struct TBAKit {

    internal var apiKey: String
    internal var session: TBASession
    internal var cacheStore: CacheStore?

    public init(apiKey: String, session: TBASession? = nil, cacheStore: CacheStore? = nil) {
        self.apiKey = apiKey
        self.session = session ?? URLSession.init(configuration: .default)
        self.cacheStore = cacheStore
    }

    public func clearCache() {
        cacheStore?.clear()
    }

    internal func decodeAndCache<T: Decodable>(response: HTTPURLResponse, data: Data) throws -> T {
        let decoded: T = try decode(data: data)
        // Only cache if we successfully decoded the data
        if response.statusCode == 200 {
            cache(response: response, data: data)
        }
        return decoded
    }

    internal func fetch<T: Decodable>(_ endpoint: String, useCache: Bool = true) async throws -> T {
        var request = try request(endpoint: endpoint)
        var postRequestBlock = { (response: HTTPURLResponse, data: Data) throws -> T in
            return try decodeAndCache(response: response, data: data)
        }
        // Swap our request for our request with cache headers
        // Swap our post-request block to return cached data, if necessary
        if useCache, let (cachedRequest, cachedData) = try? cachedRequest(endpoint: endpoint) {
            request = cachedRequest
            postRequestBlock = { (response: HTTPURLResponse, data: Data) -> T in
                // Decode from our cached data
                if response.statusCode == 304 {
                    return try decode(data: cachedData)
                }
                return try postRequestBlock(response, data)
            }
        }
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidHTTPResponse
        }
        return try postRequestBlock(response, data)
    }

    private static func url(forEndpoint endpoint: String) -> URL? {
        return URL(string: endpoint, relativeTo: APIConstants.baseURL)
    }

    private func cache(response: HTTPURLResponse, data: Data) {
        guard let url = response.url else {
            return
        }
        guard let lastModified = response.allHeaderFields["Last-Modified"] as? String else {
            return
        }
        guard let etag = response.allHeaderFields["Etag"] as? String else {
            return
        }
        cacheStore?.set(CachedResponse(url: url, lastModified: lastModified, etag: etag, data: data), forURL: url)
    }

    private func request(endpoint: String) throws -> URLRequest {
        guard let url = TBAKit.url(forEndpoint: endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-TBA-Auth-Key")
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")

        return request
    }

    private func cachedRequest(endpoint: String) throws -> (URLRequest, Data)? {
        guard let url = TBAKit.url(forEndpoint: endpoint) else {
            throw APIError.invalidURL
        }

        guard let cache = cacheStore?.get(forURL: url) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.addValue(cache.lastModified, forHTTPHeaderField: "If-Modified-Since")
        request.addValue(cache.etag, forHTTPHeaderField: "If-None-Match")

        return (request, cache.data)
    }

    private func decode<T: Decodable>(data: Data) throws -> T {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        do {
            return try decoder.decode(T.self, from: data)
        }
        catch {
            throw APIError.invalidResponse(error)
        }
    }

}
