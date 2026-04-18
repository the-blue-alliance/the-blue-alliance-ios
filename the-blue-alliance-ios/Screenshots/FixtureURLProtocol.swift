#if SCREENSHOT_MODE
import Foundation

final class FixtureURLProtocol: URLProtocol {

    override class func canInit(with request: URLRequest) -> Bool {
        guard let host = request.url?.host else { return false }
        return host.contains("thebluealliance.com")
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let key = Self.fixtureKey(for: request)

        if let url = Bundle.main.url(forResource: key, withExtension: nil, subdirectory: "ScreenshotFixtures"),
           let data = try? Data(contentsOf: url) {
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: "HTTP/1.1",
                                           headerFields: ["Content-Type": "application/json"])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        } else {
            print("[FixtureURLProtocol] missing fixture for \(key)")
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 404,
                                           httpVersion: "HTTP/1.1",
                                           headerFields: ["Content-Type": "application/json"])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data("{}".utf8))
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    // Maps a URL to a fixture filename:
    //   /api/v3/events/2024             -> events_2024.json
    //   /api/v3/event/2024miket/matches -> event_2024miket_matches.json
    //   /api/v3/team/frc604?foo=1&bar=2 -> team_frc604_bar=2&foo=1.json
    static func fixtureKey(for request: URLRequest) -> String {
        guard let url = request.url else { return "unknown.json" }
        var path = url.path
        if path.hasPrefix("/api/v3/") {
            path = String(path.dropFirst("/api/v3/".count))
        } else if path.hasPrefix("/") {
            path = String(path.dropFirst())
        }
        var key = path.replacingOccurrences(of: "/", with: "_")
        if let query = url.query, !query.isEmpty {
            let sorted = query
                .split(separator: "&")
                .map(String.init)
                .sorted()
                .joined(separator: "&")
            key += "_\(sorted)"
        }
        return "\(key).json"
    }
}
#endif
