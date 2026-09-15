import Foundation
import TBAAPI
import Testing

@testable import The_Blue_Alliance

struct DashboardPhaseTests {

    // A 2026-shaped season: Week 0 events in late February, six competition weeks, DCMPs,
    // Championship at the end of April, Israel's districts in July, offseasons through fall.
    private static let season2026: [Event] = [
        APIFixtures.event(key: "2026week0", eventType: .preseason, startDate: "2026-02-21", endDate: "2026-02-22"),
        APIFixtures.event(key: "2026wk1", startDate: "2026-03-05", endDate: "2026-03-07", week: 0),
        APIFixtures.event(key: "2026wk2", eventType: .district, startDate: "2026-03-12", endDate: "2026-03-14", week: 1),
        APIFixtures.event(key: "2026wk3", startDate: "2026-03-19", endDate: "2026-03-21", week: 2),
        APIFixtures.event(key: "2026wk4", startDate: "2026-03-26", endDate: "2026-03-28", week: 3),
        APIFixtures.event(key: "2026wk5", startDate: "2026-04-02", endDate: "2026-04-04", week: 4),
        APIFixtures.event(key: "2026micmp", eventType: .districtChampionship, startDate: "2026-04-15", endDate: "2026-04-18", week: 5),
        APIFixtures.event(key: "2026cur", eventType: .championshipDivision, startDate: "2026-04-29", endDate: "2026-05-02", parentEventKey: "2026cmptx"),
        APIFixtures.event(key: "2026cmptx", eventType: .championshipFinals, startDate: "2026-05-02", endDate: "2026-05-02"),
        APIFixtures.event(key: "2026isde1", eventType: .district, startDate: "2026-06-28", endDate: "2026-06-29", week: 16),
        APIFixtures.event(key: "2026iscmp", eventType: .districtChampionship, startDate: "2026-07-06", endDate: "2026-07-08", week: 18),
        APIFixtures.event(key: "2026cc", eventType: .offseason, startDate: "2026-09-18", endDate: "2026-09-20"),
    ]

    private static let season2027: [Event] = [
        APIFixtures.event(key: "2027wk1", startDate: "2027-03-04", endDate: "2027-03-06", week: 0)
    ]

    private static let kickoff2027 = APIFixtures.date("2027-01-09T17:00:00Z")

    private static func resolve(
        now: String,
        currentSeason: Int = 2026,
        maxSeason: Int = 2027,
        kickoff: Date? = kickoff2027,
        currentSeasonEvents: [Event] = season2026,
        nextSeasonEvents: [Event] = season2027
    ) -> DashboardPhase {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        return DashboardPhase.resolve(
            .init(
                now: APIFixtures.date(now),
                currentSeason: currentSeason,
                maxSeason: maxSeason,
                kickoff: kickoff,
                currentSeasonEvents: currentSeasonEvents,
                nextSeasonEvents: nextSeasonEvents,
                calendar: utc
            )
        )
    }

    // MARK: - After the season

    @Test func afterChampionship_isOffseasonUntilTheCountdownWindow() {
        #expect(Self.resolve(now: "2026-05-03T12:00:00Z") == .offseason(season: 2026))
        #expect(Self.resolve(now: "2026-09-08T12:00:00Z") == .offseason(season: 2026))
        #expect(Self.resolve(now: "2026-10-31T12:00:00Z") == .offseason(season: 2026))
    }

    @Test func lateDistrictEventsDoNotExtendTheSeason() {
        // Israel's district championship is live, but Championship already ended the season.
        #expect(Self.resolve(now: "2026-07-07T12:00:00Z") == .offseason(season: 2026))
    }

    @Test func countdownWindowOpensNovemberFirst() {
        #expect(
            Self.resolve(now: "2026-11-01T12:00:00Z")
                == .preKickoff(season: 2027, kickoff: Self.kickoff2027)
        )
        #expect(
            Self.resolve(now: "2027-01-09T16:59:00Z")
                == .preKickoff(season: 2027, kickoff: Self.kickoff2027)
        )
    }

    @Test func kickoffLastsThroughTheNextDay() {
        #expect(
            Self.resolve(now: "2027-01-09T17:00:00Z")
                == .kickoff(season: 2027, kickoff: Self.kickoff2027)
        )
        #expect(
            Self.resolve(now: "2027-01-10T16:00:00Z")
                == .kickoff(season: 2027, kickoff: Self.kickoff2027)
        )
    }

    @Test func buildSeason_beforeTheServerFlipsTheYear() {
        let phase = Self.resolve(now: "2027-02-01T12:00:00Z")
        #expect(
            phase == .buildSeason(season: 2027, firstEventStart: APIFixtures.date("2027-03-04T00:00:00Z"))
        )
    }

    @Test func buildSeason_afterTheServerFlipsTheYear() {
        let phase = Self.resolve(
            now: "2027-02-01T12:00:00Z",
            currentSeason: 2027,
            currentSeasonEvents: Self.season2027,
            nextSeasonEvents: []
        )
        #expect(
            phase == .buildSeason(season: 2027, firstEventStart: APIFixtures.date("2027-03-04T00:00:00Z"))
        )
    }

    // MARK: - Kickoff date sources

    @Test func serverKickoffForAnotherSeasonIsIgnored() {
        // A stale 2026 kickoff while asking about 2027 falls back to the local rule.
        let stale = APIFixtures.date("2026-01-10T17:00:00Z")
        let phase = Self.resolve(now: "2026-12-01T12:00:00Z", kickoff: stale)
        #expect(phase == .preKickoff(season: 2027, kickoff: Kickoff.date(for: 2027)))
    }

    @Test func withoutAServerKickoff_countsDownOnceNextSeasonIsListed() {
        #expect(
            Self.resolve(now: "2026-12-01T12:00:00Z", kickoff: nil)
                == .preKickoff(season: 2027, kickoff: Kickoff.date(for: 2027))
        )
    }

    @Test func withoutAServerKickoff_staysOffseasonUntilNextSeasonIsListed() {
        #expect(
            Self.resolve(now: "2026-12-01T12:00:00Z", maxSeason: 2026, kickoff: nil, nextSeasonEvents: [])
                == .offseason(season: 2026)
        )
    }

    // MARK: - During the season

    @Test func competition_landsOnTheFirstUnfinishedWeek() {
        #expect(
            Self.resolve(now: "2026-03-20T12:00:00Z")
                == .competition(season: 2026, week: 2, weekLabel: "Week 3", totalWeeks: 6)
        )
    }

    @Test func competition_rollsToNextWeekTheDayAfterAnEventEnds() {
        #expect(
            Self.resolve(now: "2026-03-22T12:00:00Z")
                == .competition(season: 2026, week: 3, weekLabel: "Week 4", totalWeeks: 6)
        )
    }

    @Test func competition_startsWithTheFirstOfficialEvent() {
        // Week 0 events in February are build season; Week 1's first day is competition.
        #expect(
            Self.resolve(now: "2026-02-22T12:00:00Z", currentSeason: 2026)
                == .buildSeason(season: 2026, firstEventStart: APIFixtures.date("2026-03-05T00:00:00Z"))
        )
        #expect(
            Self.resolve(now: "2026-03-05T00:00:00Z")
                == .competition(season: 2026, week: 0, weekLabel: "Week 1", totalWeeks: 6)
        )
    }

    @Test func districtChampionshipWeek_isStillCompetition() {
        #expect(
            Self.resolve(now: "2026-04-16T12:00:00Z")
                == .competition(season: 2026, week: 5, weekLabel: "Week 6", totalWeeks: 6)
        )
    }

    @Test func championship_whileAnyChampionshipEventIsLive() {
        #expect(Self.resolve(now: "2026-04-30T12:00:00Z") == .championship(season: 2026))
        #expect(Self.resolve(now: "2026-05-02T20:00:00Z") == .championship(season: 2026))
    }

    @Test func weekLabelsFollowTheEventsTab() {
        let events2016 = [
            APIFixtures.event(key: "2016wk0", startDate: "2016-02-25", endDate: "2016-02-27", week: 0),
            APIFixtures.event(key: "2016wk1", startDate: "2016-03-03", endDate: "2016-03-05", week: 1),
        ]
        let phase = Self.resolve(
            now: "2016-02-26T12:00:00Z",
            currentSeason: 2016,
            maxSeason: 2016,
            kickoff: nil,
            currentSeasonEvents: events2016,
            nextSeasonEvents: []
        )
        #expect(phase == .competition(season: 2016, week: 0, weekLabel: "Week 0.5", totalWeeks: 2))
    }

    @Test func seasonWithoutAChampionship_endsWithItsLastEvent() {
        let events = [
            APIFixtures.event(key: "2020wk1", startDate: "2020-02-27", endDate: "2020-02-29", week: 0),
            APIFixtures.event(key: "2020wk2", startDate: "2020-03-05", endDate: "2020-03-07", week: 1),
        ]
        let phase = Self.resolve(
            now: "2020-03-15T12:00:00Z",
            currentSeason: 2020,
            maxSeason: 2020,
            kickoff: nil,
            currentSeasonEvents: events,
            nextSeasonEvents: []
        )
        #expect(phase == .offseason(season: 2020))
    }

    @Test func seasonAccessorReturnsTheSeasonBeingShown() {
        #expect(DashboardPhase.offseason(season: 2026).season == 2026)
        #expect(DashboardPhase.preKickoff(season: 2027, kickoff: Self.kickoff2027).season == 2027)
        #expect(DashboardPhase.competition(season: 2026, week: 0, weekLabel: "", totalWeeks: 1).season == 2026)
    }

}
