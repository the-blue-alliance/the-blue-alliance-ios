//
//  TBAAPI+Event.swift
//
//
//  Created by Zachary Orr on 8/15/24.
//

extension TBAAPI {
    public func getEventsByYear(year: Year) async throws -> [Event] {
        let response = try await client.getEventsByYear(path: .init(year: year))
        return try convertResponse(response: response.ok.body.json)
    }

    public func getEventsByYearSimple(year: Year) async throws -> [Event] {
        let response = try await client.getEventsByYearSimple(path: .init(year: year))
        return try convertResponse(response: response.ok.body.json)
    }

    public func getEvent(eventKey: EventKey) async throws -> Event {
        let response = try await client.getEvent(path: .init(event_key: eventKey))
        return try convertResponse(response: response.ok.body.json)
    }

    /*
    public func getEventMatches(eventKey: EventKey) async throws -> [Match] {
        let response = try await client.getEventMatches(path: .init(event_key: eventKey))
        return try convertResponse(response: response.ok.body.json)
    }
    */
}
