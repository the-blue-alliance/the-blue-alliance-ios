import Foundation

@MainActor
final class MockURLSession {

    var stubbedData: Data?
    var stubbedResponse: URLResponse?
    var stubbedError: Error?
    private(set) var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        if let stubbedError {
            throw stubbedError
        }
        let response =
            stubbedResponse
            ?? HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        return (stubbedData ?? Data(), response)
    }

}
