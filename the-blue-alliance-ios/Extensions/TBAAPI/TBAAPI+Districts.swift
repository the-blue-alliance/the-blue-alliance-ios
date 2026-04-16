import Foundation
import TBAAPI

extension TBAAPI {

    func districtsByYear(_ year: Int) async throws -> [District] {
        let response = try await client.getDistrictsByYear(path: .init(year: year))
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

    func districtEvents(key districtKey: String) async throws -> [Event] {
        let response = try await client.getDistrictEvents(path: .init(districtKey: districtKey))
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

    func districtTeams(key districtKey: String) async throws -> [Team] {
        let response = try await client.getDistrictTeams(path: .init(districtKey: districtKey))
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

    func districtRankings(key districtKey: String) async throws -> [DistrictRanking] {
        let response = try await client.getDistrictRankings(path: .init(districtKey: districtKey))
        switch response {
        case .ok(let ok):
            return try ok.body.json ?? []
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
