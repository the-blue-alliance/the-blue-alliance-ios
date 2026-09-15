import Foundation
import TBAAPI
import Testing

@testable import The_Blue_Alliance

@MainActor
struct DashboardFeedBuilderTests {

    // Friday afternoon of Week 3, 2026. Mon Mar 16 through Sun Mar 22 is "this week".
    private static let now = APIFixtures.date("2026-03-20T15:00:00Z")

    private static let live = APIFixtures.event(key: "2026wk3", startDate: "2026-03-19", endDate: "2026-03-21", week: 2)
    private static let justEnded = APIFixtures.event(key: "2026wk3b", startDate: "2026-03-17", endDate: "2026-03-18", week: 2)
    private static let lastWeek = APIFixtures.event(key: "2026wk2", startDate: "2026-03-12", endDate: "2026-03-14", week: 1)
    private static let nextWeek = APIFixtures.event(key: "2026wk4", startDate: "2026-03-26", endDate: "2026-03-28", week: 3)
    private static let inTwoWeeks = APIFixtures.event(key: "2026wk5", startDate: "2026-04-02", endDate: "2026-04-04", week: 4)
    private static let champs = APIFixtures.event(key: "2026cur", eventType: .championshipDivision, startDate: "2026-04-29", endDate: "2026-05-02")

    private static let seasonEvents = [live, justEnded, lastWeek, nextWeek, inTwoWeeks, champs]
    private static let phase = DashboardPhase.competition(season: 2026, week: 2, weekLabel: "Week 3", totalWeeks: 6)

    private static func context(isSignedIn: Bool = true) -> DashboardFeedBuilder.Context {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        return .init(
            phase: phase,
            seasonEvents: seasonEvents,
            isSignedIn: isSignedIn,
            now: now,
            calendar: utc
        )
    }

    /// 254 is competing now, 1678 competes next week, 118 finished yesterday.
    private static func makeAPI() -> MockTBAAPI {
        let api = MockTBAAPI()
        api.teamsByKey = [
            "frc254": APIFixtures.team(254, nickname: "The Cheesy Poofs"),
            "frc1678": APIFixtures.team(1678, nickname: "Citrus Circuits"),
            "frc118": APIFixtures.team(118, nickname: "Robonauts"),
        ]
        api.teamEventsByTeam = [
            "frc254": [live, inTwoWeeks, champs],
            "frc1678": [lastWeek, nextWeek],
            "frc118": [justEnded],
        ]
        api.teamEventStatuses = [
            "frc254@2026wk3": APIFixtures.status(nextMatchKey: "2026wk3_qm40", lastMatchKey: "2026wk3_qm31"),
            "frc118@2026wk3b": APIFixtures.status(lastMatchKey: "2026wk3b_f1m2"),
        ]
        api.matchesByKey = [
            "2026wk3_qm40": APIFixtures.match(key: "2026wk3_qm40", matchNumber: 40, red: ["frc254"], predictedTime: 1_774_020_000),
            "2026wk3_qm31": APIFixtures.match(key: "2026wk3_qm31", matchNumber: 31, red: ["frc254"], time: 1_774_010_000),
            "2026wk3b_f1m2": APIFixtures.match(key: "2026wk3b_f1m2", compLevel: .f, matchNumber: 2, blue: ["frc118"], time: 1_773_860_000),
        ]
        api.mediaByTeam = ["frc254": [APIFixtures.avatar(teamKey: "frc254", base64: "aGVsbG8=")]]
        api.eventsByKey = ["2026wk3": live, "2026wk4": nextWeek]
        api.rankingsByEvent = [
            "2026wk3": EventRanking(
                rankings: (1...10).map { APIFixtures.ranking(rank: $0, teamKey: $0 == 10 ? "frc254" : "frc\($0)") },
                extraStatsInfo: [],
                sortOrderInfo: []
            )
        ]
        return api
    }

    private static func build(
        follows: DashboardFeedBuilder.Follows,
        api: MockTBAAPI = makeAPI(),
        isSignedIn: Bool = true
    ) async -> [DashboardCard] {
        await DashboardFeedBuilder(api: api).build(follows: follows, context: context(isSignedIn: isSignedIn))
    }

    // MARK: - No follows

    @Test func noFollows_showsThisWeekTheSeasonAndHowToGetStarted() async {
        let cards = await Self.build(follows: .init(), isSignedIn: false)
        #expect(
            cards == [
                .thisWeekEvents(ThisWeekEventsCard(events: [Self.justEnded, Self.live])),
                .season(Self.phase),
                .getStarted(signedIn: false),
            ]
        )
    }

    @Test func signedInWithoutFavorites_stillGetsTheGetStartedCard() async {
        let cards = await Self.build(follows: .init(), isSignedIn: true)
        #expect(cards.last == .getStarted(signedIn: true))
    }

    // MARK: - Followed teams

    @Test func teamCompetingNow_getsAHeroWithStatusAndMatches() async {
        let cards = await Self.build(follows: .init(teamKeys: ["frc254"]))
        guard case .teamAtEvent(let hero)? = cards.first else {
            Issue.record("Expected a hero card first, got \(cards)")
            return
        }
        #expect(hero.team.teamNumber == 254)
        #expect(hero.event == Self.live)
        #expect(hero.status?.nextMatchKey == "2026wk3_qm40")
        #expect(hero.nextMatch?.matchNumber == 40)
        #expect(hero.lastMatch?.matchNumber == 31)
        #expect(hero.avatarBase64 == "aGVsbG8=")
    }

    @Test func upNext_listsEventsStartingWithinTwoWeeks() async {
        let cards = await Self.build(follows: .init(teamKeys: ["frc254", "frc1678"]))
        let upNext = cards.compactMap { card -> UpNextCard? in
            if case .upNext(let upNext) = card { return upNext }
            return nil
        }
        #expect(upNext.count == 1)
        #expect(upNext.first?.entries.map(\.event.key) == ["2026wk4", "2026wk5"])
        #expect(upNext.first?.entries.map { $0.team?.teamNumber } == [1678, 254])
    }

    @Test func recentResults_coverEventsThatEndedInTheLastTwoDays() async {
        let cards = await Self.build(follows: .init(teamKeys: ["frc118", "frc1678"]))
        let recent = cards.compactMap { card -> RecentResultsCard? in
            if case .recentResults(let recent) = card { return recent }
            return nil
        }
        #expect(recent.first?.entries.map(\.team.teamNumber) == [118])
        #expect(recent.first?.entries.first?.match.key == "2026wk3b_f1m2")
        #expect(!cards.contains { if case .teamAtEvent = $0 { return true } else { return false } })
    }

    @Test func heroesSortByNextMatchThenTeamNumber() async {
        let api = Self.makeAPI()
        api.teamsByKey["frc1678"] = APIFixtures.team(1678)
        api.teamEventsByTeam["frc1678"] = [Self.live]
        api.teamEventStatuses["frc1678@2026wk3"] = APIFixtures.status(nextMatchKey: "2026wk3_qm38")
        api.matchesByKey["2026wk3_qm38"] = APIFixtures.match(key: "2026wk3_qm38", matchNumber: 38, predictedTime: 1_774_019_000)

        let cards = await Self.build(follows: .init(teamKeys: ["frc254", "frc1678"]), api: api)
        let heroes = cards.compactMap { card -> Int? in
            if case .teamAtEvent(let hero) = card { return hero.team.teamNumber }
            return nil
        }
        #expect(heroes == [1678, 254])
    }

    @Test func aTeamThatFailsToLoad_dropsOnlyItself() async {
        let cards = await Self.build(follows: .init(teamKeys: ["frc9999", "frc254"]))
        let heroes = cards.compactMap { card -> Int? in
            if case .teamAtEvent(let hero) = card { return hero.team.teamNumber }
            return nil
        }
        #expect(heroes == [254])
        #expect(cards.contains(.season(Self.phase)))
    }

    // MARK: - Followed events

    @Test func followedEventLive_keepsTheTopEightPlusFollowedTeams() async {
        let cards = await Self.build(follows: .init(teamKeys: ["frc254"], eventKeys: ["2026wk3"]))
        let live = cards.compactMap { card -> EventLiveCard? in
            if case .followedEventLive(let live) = card { return live }
            return nil
        }
        #expect(live.count == 1)
        #expect(live.first?.rankings.map(\.rank) == [1, 2, 3, 4, 5, 6, 7, 8, 10])
        #expect(live.first?.followedTeamKeys == ["frc254"])
        #expect(live.first?.alliances == nil)
    }

    @Test func followedEventUpcoming_appearsInUpNextWithoutATeam() async {
        let cards = await Self.build(follows: .init(eventKeys: ["2026wk4"]))
        #expect(
            cards.first
                == .upNext(UpNextCard(entries: [.init(team: nil, event: Self.nextWeek)]))
        )
    }

    // MARK: - Ordering

    @Test func cardsKeepAFixedOrder() async {
        let cards = await Self.build(
            follows: .init(teamKeys: ["frc254", "frc118"], eventKeys: ["2026wk3", "2026wk4"])
        )
        let kinds = cards.map { card -> String in
            switch card {
            case .teamAtEvent: return "hero"
            case .followedEventLive: return "eventLive"
            case .upNext: return "upNext"
            case .recentResults: return "recent"
            case .thisWeekEvents: return "thisWeek"
            case .season: return "season"
            case .getStarted: return "getStarted"
            }
        }
        #expect(kinds == ["hero", "eventLive", "upNext", "recent", "thisWeek", "season"])
    }

    // MARK: - Loading

    @Test func load_resolvesThePhaseAndFetchesNextSeasonWhenListed() async {
        let api = Self.makeAPI()
        api.eventsByYear = [2026: Self.seasonEvents, 2027: []]
        let status = AppStatus(
            currentSeason: 2026,
            maxSeason: 2027,
            minAppVersion: -1,
            latestAppVersion: -1,
            isDatafeedDown: false,
            downEventKeys: [],
            kickoffDate: APIFixtures.date("2027-01-09T17:00:00Z")
        )
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt

        let result = await DashboardFeedBuilder(api: api).load(
            follows: .init(teamKeys: ["frc254"]),
            status: status,
            isSignedIn: true,
            now: Self.now,
            calendar: utc
        )
        #expect(result.phase == .competition(season: 2026, week: 2, weekLabel: "Week 3", totalWeeks: 5))
        #expect(api.requestedPaths.contains("events/2026"))
        #expect(api.requestedPaths.contains("events/2027"))
        #expect(api.requestedPaths.contains("team/frc254/events/2026"))
    }

    @Test func load_usesNextSeasonEventsOnceThePhaseMovesOn() async {
        let api = Self.makeAPI()
        let next = APIFixtures.event(key: "2027wk1", startDate: "2027-03-04", endDate: "2027-03-06", week: 0)
        api.eventsByYear = [2026: Self.seasonEvents, 2027: [next]]
        api.teamEventsByTeam["frc254"] = [next]
        let status = AppStatus(
            currentSeason: 2026,
            maxSeason: 2027,
            minAppVersion: -1,
            latestAppVersion: -1,
            isDatafeedDown: false,
            downEventKeys: [],
            kickoffDate: APIFixtures.date("2027-01-09T17:00:00Z")
        )

        let result = await DashboardFeedBuilder(api: api).load(
            follows: .init(teamKeys: ["frc254"]),
            status: status,
            isSignedIn: true,
            now: APIFixtures.date("2027-02-25T12:00:00Z")
        )
        #expect(result.phase == .buildSeason(season: 2027, firstEventStart: APIFixtures.date("2027-03-04T00:00:00Z")))
        #expect(api.requestedPaths.contains("team/frc254/events/2027"))
        #expect(
            result.cards.contains(.upNext(UpNextCard(entries: [.init(team: APIFixtures.team(254, nickname: "The Cheesy Poofs"), event: next)])))
        )
    }

}
