import Foundation
import MyTBAKit
import TBAAPI
import TBAAuth
import UIKit

@testable import The_Blue_Alliance

struct Unstubbed: Error {}

/// Every endpoint throws until a test stubs it; add a stored property per endpoint as needed.
@MainActor
final class MockTBAAPI: TBAAPIProtocol {

    var teams: [TeamSimple] = []
    var teamsByKey: [TeamKey: Team] = [:]

    func setCachePolicy(_ policy: TBAAPI.CachePolicy) async {}
    func clearCache() async {}
    func getStatus() async throws -> APIStatus { throw Unstubbed() }
    func getSearchIndex() async throws -> SearchIndex { throw Unstubbed() }
    func allTeams() async throws -> [Team] { throw Unstubbed() }
    func allTeamsSimple() async throws -> [TeamSimple] { teams }
    func team(key teamKey: TeamKey) async throws -> Team {
        guard let team = teamsByKey[teamKey] else { throw Unstubbed() }
        return team
    }
    func teamYearsParticipated(key teamKey: TeamKey) async throws -> [Int] { throw Unstubbed() }
    func teamEventsByYear(key teamKey: TeamKey, year: Int) async throws -> [Event] { throw Unstubbed() }
    func teamEventMatches(teamKey: TeamKey, eventKey: EventKey) async throws -> [Match] { throw Unstubbed() }
    func teamEventAwards(teamKey: TeamKey, eventKey: EventKey) async throws -> [Award] { throw Unstubbed() }
    func teamEventStatus(teamKey: TeamKey, eventKey: EventKey) async throws -> TeamEventStatus { throw Unstubbed() }
    func teamMediaByYear(teamKey: TeamKey, year: Int) async throws -> [Media] { throw Unstubbed() }
    func eventTeamsStatuses(key eventKey: EventKey) async throws -> [String: TeamEventStatus] { throw Unstubbed() }
    func eventsByYear(_ year: Int) async throws -> [Event] { throw Unstubbed() }
    func event(key eventKey: EventKey) async throws -> Event { throw Unstubbed() }
    func eventTeams(key eventKey: EventKey) async throws -> [Team] { throw Unstubbed() }
    func eventTeamsSimple(key eventKey: EventKey) async throws -> [TeamSimple] { throw Unstubbed() }
    func eventRankings(key eventKey: EventKey) async throws -> EventRanking { throw Unstubbed() }
    func eventAlliances(key eventKey: EventKey) async throws -> [EliminationAlliance]? { throw Unstubbed() }
    func eventAwards(key eventKey: EventKey) async throws -> [Award] { throw Unstubbed() }
    func eventDistrictPoints(key eventKey: EventKey) async throws -> EventDistrictPoints { throw Unstubbed() }
    func eventInsights(key eventKey: EventKey) async throws -> EventInsights { throw Unstubbed() }
    func eventMatches(key eventKey: EventKey) async throws -> [Match] { throw Unstubbed() }
    func match(key matchKey: String) async throws -> Match { throw Unstubbed() }
    func eventOPRs(key eventKey: EventKey) async throws -> EventOPRs { throw Unstubbed() }
    func districtsByYear(_ year: Int) async throws -> [District] { throw Unstubbed() }
    func districtEvents(key districtKey: String) async throws -> [Event] { throw Unstubbed() }
    func districtTeams(key districtKey: String) async throws -> [Team] { throw Unstubbed() }
    func districtTeamsSimple(key districtKey: String) async throws -> [TeamSimple] { throw Unstubbed() }
    func districtRankings(key districtKey: String) async throws -> [DistrictRanking]? { throw Unstubbed() }

}

final class MockStatusService: StatusServiceProtocol {
    var status: AppStatus = .default
    var currentSeason: Int { status.currentSeason }
    var maxSeason: Int { status.maxSeason }
    func registerForStatusChanges(_ subscriber: StatusSubscribable) {}
    func registerForFMSStatusChanges(_ subscriber: FMSStatusSubscribable) {}
    func registerForEventStatusChanges(_ subscriber: EventStatusSubscribable, eventKey: EventKey) {}
    func start() {}
}

final class MockURLOpener: URLOpener {
    private(set) var opened: [URL] = []
    func canOpenURL(_ url: URL) -> Bool { true }
    func open(_ url: URL) {
        opened.append(url)
    }
}

extension Dependencies {

    static func mock(api: MockTBAAPI = MockTBAAPI()) -> Dependencies {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let callLog = CallLog()
        let authService = MockAuthService(callLog: callLog)
        let myTBA = MockSessionMyTBA(callLog: callLog)
        let reporter = MockReporter()
        let stores = MyTBAStores(
            favorites: FavoritesStore(fileURL: directory.appendingPathComponent("favorites.json")),
            subscriptions: SubscriptionsStore(
                fileURL: directory.appendingPathComponent("subscriptions.json")
            )
        )
        return Dependencies(
            api: api,
            appSettings: AppSettings(defaults: UserDefaults(suiteName: UUID().uuidString)!),
            authService: authService,
            myTBA: myTBA,
            myTBAStores: stores,
            myTBASession: MyTBASessionService(
                authService: authService,
                myTBA: myTBA,
                myTBAStores: stores,
                pushService: MockPushService(callLog: callLog),
                reporter: reporter,
                applicationState: { .active }
            ),
            reporter: reporter,
            statusService: MockStatusService(),
            urlOpener: MockURLOpener()
        )
    }

}
