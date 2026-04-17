import Foundation

public protocol TBAAPIProtocol {
    // Status
    func getStatus() async throws -> APIStatus

    // Search
    func getSearchIndex() async throws -> SearchIndex

    // Teams
    func allTeams() async throws -> [Team]
    func allTeamsSimple() async throws -> [TeamSimple]
    func team(key teamKey: String) async throws -> Team?
    func teamYearsParticipated(key teamKey: String) async throws -> [Int]
    func teamEventsByYear(key teamKey: String, year: Int) async throws -> [Event]
    func teamEventMatches(teamKey: String, eventKey: String) async throws -> [Match]
    func teamEventAwards(teamKey: String, eventKey: String) async throws -> [Award]
    func teamEventStatus(teamKey: String, eventKey: String) async throws -> TeamEventStatus?
    func teamMediaByYear(teamKey: String, year: Int) async throws -> [Media]

    // Events
    func eventsByYear(_ year: Int) async throws -> [Event]
    func event(key eventKey: String) async throws -> Event
    func eventTeams(key eventKey: String) async throws -> [Team]
    func eventRankings(key eventKey: String) async throws -> EventRanking?
    func eventAlliances(key eventKey: String) async throws -> [EliminationAlliance]?
    func eventAwards(key eventKey: String) async throws -> [Award]
    func eventDistrictPoints(key eventKey: String) async throws -> EventDistrictPoints?
    func eventInsights(key eventKey: String) async throws -> EventInsights?
    func eventMatches(key eventKey: String) async throws -> [Match]
    func match(key matchKey: String) async throws -> Match?
    func eventOPRs(key eventKey: String) async throws -> EventOPRs?

    // Districts
    func districtsByYear(_ year: Int) async throws -> [District]
    func districtEvents(key districtKey: String) async throws -> [Event]
    func districtTeams(key districtKey: String) async throws -> [Team]
    func districtTeamsSimple(key districtKey: String) async throws -> [TeamSimple]
    func districtRankings(key districtKey: String) async throws -> [DistrictRanking]
}
