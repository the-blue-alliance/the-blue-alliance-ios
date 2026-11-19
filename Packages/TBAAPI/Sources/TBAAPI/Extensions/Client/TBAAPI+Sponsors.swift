import Foundation

nonisolated extension TBAAPI {

    public func getSponsors() async throws -> [Sponsor] {
        let response = try await client.getSponsors()
        switch response {
        case .ok(let ok):
            return try ok.body.json.sponsors
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
