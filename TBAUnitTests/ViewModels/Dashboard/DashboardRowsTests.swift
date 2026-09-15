import Foundation
import TBAAPI
import Testing

@testable import The_Blue_Alliance

@MainActor
struct DashboardRowsTests {

    private static let now = APIFixtures.date("2026-03-20T15:00:00Z")
    private static let live = APIFixtures.event(
        key: "2026wk3",
        startDate: "2026-03-19",
        endDate: "2026-03-21",
        week: 2,
        name: "Kearsley"
    )
    private static let nextWeek = APIFixtures.event(
        key: "2026wk4",
        startDate: "2026-03-26",
        endDate: "2026-03-28",
        week: 3,
        name: "California Northern"
    )
    private static let competition = DashboardPhase.competition(
        season: 2026,
        week: 2,
        weekLabel: "Week 3",
        totalWeeks: 6
    )

    private static func rows(_ items: [DashboardItem]) -> [DashboardRow] {
        items.compactMap { item in
            guard case .row(let row) = item else { return nil }
            return row
        }
    }

    // MARK: - Layout

    @Test func summaryLeadsWithTheSeasonThenThisWeek() {
        let sections = DashboardRows.sections(
            for: [
                .thisWeekEvents(ThisWeekEventsCard(events: [Self.live, Self.nextWeek])),
                .season(Self.competition),
                .getStarted(signedIn: false),
            ],
            now: Self.now
        )
        #expect(sections.map { $0.0.id } == ["summary", "getStarted"])
        #expect(sections.map { $0.0.title } == [nil, "Get started"])

        let summary = sections[0].1
        guard case .summary(let viewModel, let action)? = summary.first else {
            Issue.record("Expected the season summary first, got \(summary)")
            return
        }
        #expect(viewModel.headline == "Week 3")
        #expect(viewModel.title == "of the 2026 season")
        #expect(viewModel.progress == 0.5)
        #expect(action == .tab(.events))

        let week = Self.rows(summary)
        #expect(week.map(\.title) == ["Events this week"])
        #expect(week.first?.value == "2")
        #expect(week.first?.action == .tab(.events))
    }

    @Test func onlyTheFirstCompetingTeamIsTitled() {
        let first = TeamAtEventCard(
            team: APIFixtures.team(254),
            event: Self.live,
            status: nil,
            nextMatch: nil,
            lastMatch: nil,
            avatarBase64: nil
        )
        let second = TeamAtEventCard(
            team: APIFixtures.team(1678),
            event: Self.live,
            status: nil,
            nextMatch: nil,
            lastMatch: nil,
            avatarBase64: nil
        )
        let sections = DashboardRows.sections(
            for: [.teamAtEvent(first), .teamAtEvent(second)],
            now: Self.now
        )
        #expect(sections.map { $0.0.title } == ["Competing now", nil])
    }

    // MARK: - Cards

    @Test func hero_headerThenValueRows() {
        let next = APIFixtures.match(key: "2026wk3_qm40", matchNumber: 40, red: ["frc254"])
        var last = APIFixtures.match(
            key: "2026wk3_qm31",
            matchNumber: 31,
            red: ["frc254"],
            blue: ["frc1"]
        )
        last.alliances.red.score = 120
        last.alliances.blue.score = 98
        last.winningAlliance = .red

        let hero = TeamAtEventCard(
            team: APIFixtures.team(254, nickname: "The Cheesy Poofs"),
            event: Self.live,
            status: TeamEventStatus(
                qual: .init(
                    numTeams: 41,
                    ranking: .init(record: .init(losses: 1, wins: 11, ties: 0), rank: 2)
                ),
                alliance: .init(number: 1, pick: 0),
                pitLocation: "B2"
            ),
            nextMatch: next,
            lastMatch: last,
            avatarBase64: nil
        )
        let (section, items) = DashboardRows.rows(for: .teamAtEvent(hero), now: Self.now)

        #expect(section.title == "Competing now")
        guard case .teamHeader? = items.first else {
            Issue.record("Expected the team header first, got \(items)")
            return
        }
        let rows = Self.rows(items)
        #expect(rows.map(\.title) == ["Rank", "Record", "Alliance", "Pit", "Next match", "Last match"])
        #expect(
            rows.map(\.value) == [
                "2nd of 41", "11-1-0", "Alliance 1 captain", "B2", "Quals 40", "Quals 31 · Won 120–98",
            ]
        )
        #expect(rows[4].action == .match(next, teamKey: "frc254"))
        #expect(rows[0].action == nil)
    }

    @Test func recentResults_showTheTeamMatchAndResult() {
        var match = APIFixtures.match(
            key: "2026wk3_f1m2",
            compLevel: .f,
            matchNumber: 2,
            red: ["frc254"],
            blue: ["frc1"]
        )
        match.alliances.red.score = 98
        match.alliances.blue.score = 120
        match.winningAlliance = .blue
        let card = RecentResultsCard(entries: [
            .init(team: APIFixtures.team(254), event: Self.live, match: match)
        ])

        let (section, items) = DashboardRows.rows(for: .recentResults(card), now: Self.now)
        #expect(section.title == "Recent results")
        let rows = Self.rows(items)
        #expect(rows.map(\.title) == ["254 · Finals 1-2"])
        #expect(rows.map(\.value) == ["Lost 98–120"])
    }

    @Test func upNext_groupsTeamsHeadedToTheSameEvent() {
        let card = UpNextCard(entries: [
            .init(team: APIFixtures.team(254, nickname: "The Cheesy Poofs"), event: Self.nextWeek),
            .init(team: APIFixtures.team(1678, nickname: "Citrus Circuits"), event: Self.nextWeek),
            .init(team: nil, event: Self.live),
        ])
        let (section, items) = DashboardRows.rows(for: .upNext(card), now: Self.now)

        #expect(section.title == "Up next")
        #expect(items.count == 2)
        guard case .upNext(let event, let teamKeys, let viewModel)? = items.first else {
            Issue.record("Expected an up-next row, got \(items)")
            return
        }
        #expect(event.key == "2026wk4")
        #expect(teamKeys == ["frc254", "frc1678"])
        #expect(viewModel.month == "Mar")
        #expect(viewModel.day == "26")
        #expect(viewModel.detail == "254, 1678")
        #expect(viewModel.relative == "In 6 days")
    }

    @Test func upNext_singleTeamShowsItsNickname() {
        let card = UpNextCard(entries: [
            .init(team: APIFixtures.team(254, nickname: "The Cheesy Poofs"), event: Self.nextWeek)
        ])
        let (_, items) = DashboardRows.rows(for: .upNext(card), now: Self.now)
        guard case .upNext(_, let teamKeys, let viewModel)? = items.first else { return }
        #expect(teamKeys == ["frc254"])
        #expect(viewModel.detail == "254 The Cheesy Poofs")
    }

    @Test func season_countsDownToKickoffInDays() {
        let kickoff = APIFixtures.date("2027-01-09T17:00:00Z")
        let (_, items) = DashboardRows.rows(
            for: .season(.preKickoff(season: 2027, kickoff: kickoff)),
            now: APIFixtures.date("2026-12-01T17:00:00Z")
        )
        guard case .summary(let viewModel, let action)? = items.first else { return }
        #expect(viewModel.headline == "39 days")
        #expect(viewModel.title == "until 2027 Kickoff")
        #expect(action == nil)
    }

    @Test func getStarted_offersMyTBAAndSearchTiles() {
        let (section, signedOut) = DashboardRows.rows(
            for: .getStarted(signedIn: false),
            now: Self.now
        )
        #expect(section.title == "Get started")
        guard case .tiles(_, let tiles)? = signedOut.first else { return }
        #expect(tiles.map(\.title) == ["Sign in to follow your teams", "Find a team or event"])
        #expect(tiles.map(\.tab) == [.myTBA, .search])

        let (_, signedIn) = DashboardRows.rows(for: .getStarted(signedIn: true), now: Self.now)
        guard case .tiles(_, let signedInTiles)? = signedIn.first else { return }
        #expect(signedInTiles.first?.title == "Favorite the teams you follow")
    }

}
