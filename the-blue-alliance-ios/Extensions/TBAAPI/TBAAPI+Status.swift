import Foundation
import TBAAPI

extension TBAAPI: TBAAPIProtocol {}

extension TBAAPI {

    public func getStatus() async throws -> APIStatus {
        let response = try await client.getStatus()
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
