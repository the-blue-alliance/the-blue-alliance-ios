import Foundation
import TBAAPI

@testable import The_Blue_Alliance

/// Minimal API models for tests that only care about keys, dates, and types.
enum APIFixtures {

    static func event(
        key: String,
        eventType: APIEventType = .regional,
        startDate: String,
        endDate: String,
        week: Int? = nil,
        name: String = "",
        parentEventKey: String? = nil
    ) -> Event {
        let year = Int(key.prefix(4)) ?? 0
        return Event(
            key: key,
            name: name,
            eventCode: String(key.dropFirst(4)),
            eventType: Components.Schemas.EventType(rawValue: eventType.rawValue) ?? ._0,
            startDate: startDate,
            endDate: endDate,
            year: year,
            eventTypeString: "",
            week: week,
            webcasts: [],
            divisionKeys: [],
            parentEventKey: parentEventKey
        )
    }

    static func team(_ number: Int, nickname: String = "") -> Team {
        Team(
            key: "frc\(number)",
            teamNumber: number,
            nickname: nickname,
            name: "",
            city: nil,
            stateProv: nil,
            country: nil,
            locationName: nil,
            website: nil
        )
    }

    static func match(
        key: String,
        compLevel: CompLevel = .qm,
        matchNumber: Int = 1,
        red: [String] = [],
        blue: [String] = [],
        time: Int64? = nil,
        predictedTime: Int64? = nil
    ) -> Match {
        Match(
            key: key,
            compLevel: compLevel,
            setNumber: 1,
            matchNumber: matchNumber,
            alliances: Match.AlliancesPayload(
                red: MatchAlliance(score: 0, teamKeys: red, surrogateTeamKeys: [], dqTeamKeys: []),
                blue: MatchAlliance(score: 0, teamKeys: blue, surrogateTeamKeys: [], dqTeamKeys: [])
            ),
            winningAlliance: ._empty_,
            eventKey: String(key.split(separator: "_").first ?? ""),
            time: time,
            actualTime: nil,
            predictedTime: predictedTime,
            videos: []
        )
    }

    static func status(nextMatchKey: String? = nil, lastMatchKey: String? = nil) -> TeamEventStatus {
        TeamEventStatus(nextMatchKey: nextMatchKey, lastMatchKey: lastMatchKey)
    }

    static func ranking(rank: Int, teamKey: String) -> EventRanking.RankingsPayloadPayload {
        EventRanking.RankingsPayloadPayload(
            matchesPlayed: 0,
            extraStats: [],
            sortOrders: [],
            rank: rank,
            dq: 0,
            teamKey: teamKey
        )
    }

    static func avatar(teamKey: String, base64: String) -> Media {
        .avatar(
            Components.Schemas.MediaAvatar(
                value1: MediaBase(_type: .avatar, foreignKey: "avatar_\(teamKey)", teamKeys: [teamKey]),
                value2: Components.Schemas.MediaAvatarExtras(details: .init(base64Image: base64))
            )
        )
    }

    /// A UTC instant from an ISO 8601 string, e.g. `"2026-09-08T15:00:00Z"`.
    static func date(_ iso: String) -> Date {
        try! Date(iso, strategy: .iso8601)
    }

}
