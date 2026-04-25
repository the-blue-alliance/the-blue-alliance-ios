import Foundation

public protocol TBAAPIProtocol {
    // Networking
    var cachePolicy: TBAAPI.CachePolicy { get }
    func setCachePolicy(_ policy: TBAAPI.CachePolicy)
    func clearCache()

    // Status
    func getStatus() async throws -> APIStatus

    // Search
    func getSearchIndex() async throws -> SearchIndex

    // Teams
    func allTeams() async throws -> [Team]
    func allTeamsSimple() async throws -> [TeamSimple]
    func team(key teamKey: TeamKey) async throws -> Team
    func teamYearsParticipated(key teamKey: TeamKey) async throws -> [Int]
    func teamEventsByYear(key teamKey: TeamKey, year: Int) async throws -> [Event]
    func teamEventMatches(teamKey: TeamKey, eventKey: EventKey) async throws -> [Match]
    func teamEventAwards(teamKey: TeamKey, eventKey: EventKey) async throws -> [Award]
    func teamEventStatus(teamKey: TeamKey, eventKey: EventKey) async throws -> TeamEventStatus
    func teamMediaByYear(teamKey: TeamKey, year: Int) async throws -> [Media]

    func eventTeamsStatuses(key eventKey: EventKey) async throws -> [String: TeamEventStatus]

    // Events
    func eventsByYear(_ year: Int) async throws -> [Event]
    func event(key eventKey: EventKey) async throws -> Event
    func eventTeams(key eventKey: EventKey) async throws -> [Team]
    func eventTeamsSimple(key eventKey: EventKey) async throws -> [TeamSimple]
    func eventRankings(key eventKey: EventKey) async throws -> EventRanking
    func eventAlliances(key eventKey: EventKey) async throws -> [EliminationAlliance]?
    func eventAwards(key eventKey: EventKey) async throws -> [Award]
    func eventDistrictPoints(key eventKey: EventKey) async throws -> EventDistrictPoints
    func eventInsights(key eventKey: EventKey) async throws -> EventInsights
    func eventMatches(key eventKey: EventKey) async throws -> [Match]
    func match(key matchKey: String) async throws -> Match
    func eventOPRs(key eventKey: EventKey) async throws -> EventOPRs

    // Districts
    func districtsByYear(_ year: Int) async throws -> [District]
    func districtEvents(key districtKey: String) async throws -> [Event]
    func districtTeams(key districtKey: String) async throws -> [Team]
    func districtTeamsSimple(key districtKey: String) async throws -> [TeamSimple]
    func districtRankings(key districtKey: String) async throws -> [DistrictRanking]?
}
