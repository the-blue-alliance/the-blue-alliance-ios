import Foundation

extension TBAAPI {

    public func getSearchIndex() async throws -> SearchIndex {
        let response = try await client.getSearchIndex()
        switch response {
        case .ok(let ok):
            return try ok.body.json
        case .notModified:
            throw TBAAPIError.notModified
        case .unauthorized:
            throw TBAAPIError.unauthorized
        case .notFound:
            throw TBAAPIError.notFound
        case .undocumented(let statusCode, _):
            throw TBAAPIError.unexpectedStatus(statusCode)
        }
    }
}
