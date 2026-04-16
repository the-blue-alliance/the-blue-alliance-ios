import Foundation
import TBAAPI

extension TBAAPI {

    // TBA's `/teams/{page}` paginates at 500 per page. We keep fetching until
    // a page comes back empty — that's the API's signal that we're past the end.
    func allTeams() async throws -> [Components.Schemas.Team] {
        var all: [Components.Schemas.Team] = []
        var page = 0
        while true {
            let response = try await client.getTeams(path: .init(pageNum: page))
            let batch: [Components.Schemas.Team]
            switch response {
            case .ok(let ok):
                batch = try ok.body.json
            case .notModified, .unauthorized, .notFound:
                return all
            case .undocumented(let statusCode, _):
                throw TBAAPIError.unexpectedStatus(statusCode)
            }
            if batch.isEmpty { break }
            all.append(contentsOf: batch)
            page += 1
        }
        return all
    }

    func team(key teamKey: String) async throws -> Components.Schemas.Team? {
        let response = try await client.getTeam(path: .init(teamKey: teamKey))
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

    func teamYearsParticipated(key teamKey: String) async throws -> [Int] {
        let response = try await client.getTeamYearsParticipated(path: .init(teamKey: teamKey))
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

    func teamEventsByYear(key teamKey: String, year: Int) async throws -> [Components.Schemas.Event] {
        let response = try await client.getTeamEventsByYear(path: .init(teamKey: teamKey, year: year))
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

    func teamEventMatches(teamKey: String, eventKey: String) async throws -> [Components.Schemas.Match] {
        let response = try await client.getTeamEventMatches(path: .init(teamKey: teamKey, eventKey: eventKey))
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

    func teamEventAwards(teamKey: String, eventKey: String) async throws -> [Components.Schemas.Award] {
        let response = try await client.getTeamEventAwards(path: .init(teamKey: teamKey, eventKey: eventKey))
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

    func teamEventStatus(teamKey: String, eventKey: String) async throws -> Components.Schemas.TeamEventStatus? {
        let response = try await client.getTeamEventStatus(path: .init(teamKey: teamKey, eventKey: eventKey))
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

    func teamMediaByYear(teamKey: String, year: Int) async throws -> [Components.Schemas.Media] {
        let response = try await client.getTeamMediaByYear(path: .init(teamKey: teamKey, year: year))
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
