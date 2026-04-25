import Foundation

extension TBAAPI {

    // TBA's `/teams/{page}` paginates at 500 per page. We keep fetching until
    // a page comes back empty — that's the API's signal that we're past the end.
    public func allTeams() async throws -> [Team] {
        var all: [Team] = []
        var page = 0
        while true {
            let response = try await client.getTeams(path: .init(pageNum: page))
            let batch: [Team]
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

    public func allTeamsSimple() async throws -> [TeamSimple] {
        var all: [TeamSimple] = []
        var page = 0
        while true {
            let response = try await client.getTeamsSimple(path: .init(pageNum: page))
            let batch: [TeamSimple]
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

    public func team(key teamKey: TeamKey) async throws -> Team {
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

    public func teamYearsParticipated(key teamKey: TeamKey) async throws -> [Int] {
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

    public func teamEventsByYear(key teamKey: TeamKey, year: Int) async throws -> [Event] {
        let response = try await client.getTeamEventsByYear(
            path: .init(teamKey: teamKey, year: year)
        )
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

    public func teamEventMatches(teamKey: TeamKey, eventKey: EventKey) async throws -> [Match] {
        let response = try await client.getTeamEventMatches(
            path: .init(teamKey: teamKey, eventKey: eventKey)
        )
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

    public func teamEventAwards(teamKey: TeamKey, eventKey: EventKey) async throws -> [Award] {
        let response = try await client.getTeamEventAwards(
            path: .init(teamKey: teamKey, eventKey: eventKey)
        )
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

    public func teamEventStatus(teamKey: TeamKey, eventKey: EventKey) async throws
        -> TeamEventStatus
    {
        let response = try await client.getTeamEventStatus(
            path: .init(teamKey: teamKey, eventKey: eventKey)
        )
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

    public func eventTeamsStatuses(key eventKey: EventKey) async throws -> [String: TeamEventStatus]
    {
        let response = try await client.getEventTeamsStatuses(
            path: .init(eventKey: eventKey)
        )
        switch response {
        case .ok(let ok):
            return try ok.body.json.additionalProperties
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

    public func teamMediaByYear(teamKey: TeamKey, year: Int) async throws -> [Media] {
        let response = try await client.getTeamMediaByYear(
            path: .init(teamKey: teamKey, year: year)
        )
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
