import Foundation

extension TBAAPI {

    public func eventsByYear(_ year: Int) async throws -> [Event] {
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

    public func event(key eventKey: String) async throws -> Event {
        let response = try await client.getEvent(path: .init(eventKey: eventKey))
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

    public func eventTeams(key eventKey: String) async throws -> [Team] {
        let response = try await client.getEventTeams(path: .init(eventKey: eventKey))
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

    public func eventTeamsSimple(key eventKey: String) async throws -> [TeamSimple] {
        let response = try await client.getEventTeamsSimple(path: .init(eventKey: eventKey))
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

    public func eventRankings(key eventKey: String) async throws -> EventRanking {
        let response = try await client.getEventRankings(path: .init(eventKey: eventKey))
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

    public func eventAlliances(key eventKey: String) async throws -> [EliminationAlliance]? {
        let response = try await client.getEventAlliances(path: .init(eventKey: eventKey))
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

    public func eventAwards(key eventKey: String) async throws -> [Award] {
        let response = try await client.getEventAwards(path: .init(eventKey: eventKey))
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

    public func eventDistrictPoints(key eventKey: String) async throws -> EventDistrictPoints {
        let response = try await client.getEventDistrictPoints(path: .init(eventKey: eventKey))
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

    public func eventInsights(key eventKey: String) async throws -> EventInsights {
        let response = try await client.getEventInsights(path: .init(eventKey: eventKey))
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

    public func eventMatches(key eventKey: String) async throws -> [Match] {
        let response = try await client.getEventMatches(path: .init(eventKey: eventKey))
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

    public func match(key matchKey: String) async throws -> Match {
        let response = try await client.getMatch(path: .init(matchKey: matchKey))
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

    public func eventOPRs(key eventKey: String) async throws -> EventOPRs {
        let response = try await client.getEventOPRs(path: .init(eventKey: eventKey))
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
