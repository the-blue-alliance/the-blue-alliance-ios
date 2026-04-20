import Foundation

public final class MockURLSession {

    public var stubbedData: Data?
    public var stubbedResponse: URLResponse?
    public var stubbedError: Error?
    public private(set) var lastRequest: URLRequest?

    public init() {}

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        if let stubbedError {
            throw stubbedError
        }
        let response =
            stubbedResponse ?? HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        return (stubbedData ?? Data(), response)
    }

}
