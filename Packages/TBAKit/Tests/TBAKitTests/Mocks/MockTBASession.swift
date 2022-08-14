import XCTest
import TBAKit

internal struct MockResponse {
    let data: Data
    let response: HTTPURLResponse
}

public enum MockURLSessionError: Error, LocalizedError {
    case missingURL
    case invalidURL
    case missingFile
    case invalidData
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .missingURL:
            return "Missing URL"
        case .invalidURL:
            return "Invalid URL"
        case .missingFile:
            return "Missing file"
        case .invalidData:
            return "Invalid data"
        case .invalidResponse:
            return "Invalid response"
        }
    }
}

internal class MockURLSession: TBASession {

    private let bundle: Bundle

    init(bundle: Bundle = Bundle.module) {
        self.bundle = bundle
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw MockURLSessionError.missingURL
        }

        guard let components = URLComponents(string: url.absoluteString) else {
            throw MockURLSessionError.invalidURL
        }

        let filename = components.path.replacingOccurrences(of: "/api/v3/", with: "").replacingOccurrences(of: "/", with: "_")
        guard let resourceURL = bundle.url(forResource: "\(filename)", withExtension: "json", subdirectory: "Data") else {
            throw MockURLSessionError.missingFile
        }

        guard let data = try? Data(contentsOf: resourceURL) else {
            throw MockURLSessionError.invalidData
        }

        let headerFields = [
            "Last-Modified": "Sun, 11 Jun 2017 03:34:00 GMT",
            "Etag": "W/\"1ea6e1a87aafbbeeb6a89b31cf4fb84c\""
        ]

        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headerFields) else {
            throw MockURLSessionError.invalidResponse
        }

        return (data, response)
    }

}
