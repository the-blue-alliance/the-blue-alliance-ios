import Foundation
import TBAAPI

// App-facing error type for TBAAPI calls. Each wrapper translates the
// generated `Operations.*.Output` enum into either a decoded body or a
// `TBAAPIError`, so call sites only have to deal with async throws.
enum TBAAPIError: Error {
    case notModified
    case unauthorized
    case notFound
    case unexpectedStatus(Int)
}

// Thin wrappers that hide the generated `Operations.*.Output` plumbing.
// Each phase of the Core Data removal adds the wrappers it needs here.
extension TBAAPI {

    func eventsByYear(_ year: Int) async throws -> [Components.Schemas.Event] {
        let response = try await client.getEventsByYear(path: .init(year: year))
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
