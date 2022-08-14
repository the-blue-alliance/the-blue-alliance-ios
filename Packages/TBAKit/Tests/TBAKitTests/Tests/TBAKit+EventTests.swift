import XCTest
import TBAKit

final class TBAKitEventTests: TBAKitTestCase {

    func test_eventsAll() async throws {
        let events = try await kit.eventsAll()
        XCTAssertEqual(events.count, 1)
    }

    func test_eventsYear() async throws {
        let events = try await kit.events(year: 2017)
        XCTAssertEqual(events.count, 214)
    }

    func test_event() async throws {
        let event = try await kit.event(key: "2017mike2")

        XCTAssertNotNil(event.key)
        XCTAssertNotNil(event.eventCode)
        XCTAssertNotNil(event.name)
        XCTAssertNotNil(event.startDate)
        XCTAssertNotNil(event.endDate)
        XCTAssertNotNil(event.year)
    }

    func test_event_parent() async throws {
        let parentEventKey = "2017micmp"
        let childEventKey = "2017micmp3"

        let parentEvent = try await kit.event(key: parentEventKey)
        XCTAssertNotNil(parentEvent.divisionKeys)
        XCTAssert(parentEvent.divisionKeys.contains(childEventKey))

        let childEvent = try await kit.event(key: childEventKey)
        XCTAssertNotNil(childEvent.parentEventKey)
        XCTAssertEqual(childEvent.parentEventKey, parentEventKey)
    }

    func test_eventAlliances() async throws {
        let alliances = try await kit.eventAlliances(key: "2017mike2")
        XCTAssertGreaterThan(alliances.count, 0)

        let alliance = try XCTUnwrap(alliances.first)
        XCTAssertNotNil(alliance.picks)
        XCTAssertGreaterThan(alliance.picks.count, 0)
        XCTAssertNotNil(alliance.declines)
        XCTAssertNotNil(alliance.status)

        let status = try XCTUnwrap(alliance.status)
        XCTAssertNotNil(status.currentRecord)
        XCTAssertNotNil(status.level)
        XCTAssertNotNil(status.record)
        XCTAssertNotNil(status.status)

        let record = try XCTUnwrap(status.record)
        XCTAssertNotNil(record.wins)
        XCTAssertNotNil(record.losses)
        XCTAssertNotNil(record.ties)
    }

    func test_eventAlliances_backup() async throws {
        let alliances = try await kit.eventAlliances(key: "2018micmp4")
        XCTAssertGreaterThan(alliances.count, 0)

        let allianceOne = try XCTUnwrap(alliances.first)
        XCTAssertNil(allianceOne.backup)

        // backup is on the second alliance
        let allianceTwo = alliances[1]
        let backup = try XCTUnwrap(allianceTwo.backup)
        XCTAssertNotNil(backup.teamKeyIn)
        XCTAssertNotNil(backup.teamKeyOut)
    }

    func test_eventAlliances_playoffAverage() async throws {
        let alliances = try await kit.eventAlliances(key: "2015mike2")
        XCTAssertGreaterThan(alliances.count, 0)

        let alliance = try XCTUnwrap(alliances.first)
        XCTAssertNotNil(alliance.status)

        let status = try XCTUnwrap(alliance.status)
        XCTAssertNotNil(status.playoffAverage)
    }

    func test_eventAwards() async throws {
        let awards = try await kit.eventAwards(key: "2017mike2")
        XCTAssertGreaterThan(awards.count, 0)

        let award = try XCTUnwrap(awards.first)
        XCTAssertNotNil(award.awardType)
        XCTAssertNotNil(award.eventKey)
        XCTAssertNotNil(award.name)
        XCTAssertNotNil(award.awardType)
        XCTAssertNotNil(award.year)
        XCTAssertNotNil(award.recipients)
        XCTAssertGreaterThan(award.recipients.count, 0)

        let recipient = try XCTUnwrap(award.recipients.first)
        XCTAssertNotNil(recipient.teamKey)
    }

    func test_eventAwards_awardee() async throws {
        let awards = try await kit.eventAwards(key: "2015micmp")
        XCTAssertGreaterThan(awards.count, 0)

        guard let deansListAwardIndex = awards.firstIndex(where: { $0.awardType == 4 }) else {
            XCTFail()
            return
        }

        let deansListAward = awards[deansListAwardIndex]
        let recipient = try XCTUnwrap(deansListAward.recipients.first)
        XCTAssertNotNil(recipient.teamKey)
        XCTAssertNotNil(recipient.awardee)
    }

    func test_eventDistrictPoints() async throws {
        let eventDistrictPoints = try await kit.eventDistrictPoints(key: "2017mike2")

        let districtPoints = eventDistrictPoints.points
        XCTAssertGreaterThan(districtPoints.count, 0)

        let districtPoint = try XCTUnwrap(districtPoints.values.first)
        XCTAssertNil(districtPoint.eventKey)
        XCTAssertNotNil(districtPoint.alliancePoints)
        XCTAssertNotNil(districtPoint.awardPoints)
        XCTAssertNotNil(districtPoint.elimPoints)
        XCTAssertNotNil(districtPoint.qualPoints)
        XCTAssertNotNil(districtPoint.total)

        let tiebreakers = try XCTUnwrap(eventDistrictPoints.tiebreakers)
        XCTAssertGreaterThan(tiebreakers.count, 0)

        let tiebreaker = try XCTUnwrap(tiebreakers.values.first)
        XCTAssertNotNil(tiebreaker.qualWins)
        XCTAssertNotNil(tiebreaker.highestQualScores)
        XCTAssertGreaterThan(tiebreaker.highestQualScores.count, 0)
    }

    func test_eventDistrictPoints_regional() async throws {
        do {
            _ = try await kit.eventDistrictPoints(key: "2005ga")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_eventInsights() async throws {
        let insights = try await kit.eventInsights(key: "2017mike2")
        XCTAssertNotNil(insights.qual)
        XCTAssertNotNil(insights.playoff)
    }

    func test_eventInsights_null() async throws {
        do {
            _ = try await kit.eventInsights(key: "2015miket")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_eventInsights_partialNull() async throws {
        let insights = try await kit.eventInsights(key: "2016miket")
        XCTAssertNil(insights.qual)
        XCTAssertNil(insights.playoff)
    }

    func test_eventMatches() async throws {
        let matches = try await kit.eventMatches(key: "2017mike2")
        XCTAssertGreaterThan(matches.count, 0)
    }

    func test_eventStats() async throws {
        let stats = try await kit.eventStats(key: "2017mike2")
        XCTAssertGreaterThan(stats.oprs.keys.count, 0)
        XCTAssertGreaterThan(stats.dprs.keys.count, 0)
        XCTAssertGreaterThan(stats.ccwms.keys.count, 0)
    }

    func test_eventStats_null() async throws {
        do {
            _ = try await kit.eventStats(key: "1992cmp")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_eventRankings() async throws {
        let ranking = try await kit.eventRankings(key: "2017mike2")
        let rankings = try XCTUnwrap(ranking.rankings)
        XCTAssertGreaterThan(rankings.count, 0)

        let rank = try XCTUnwrap(rankings.first)
        XCTAssertNotNil(rank.teamKey)
        XCTAssertNotNil(rank.rank)
        XCTAssertNotNil(rank.record)
        XCTAssertNotNil(rank.sortOrders)
        XCTAssertNotNil(rank.extraStats)

        let sortOrderInfo = ranking.sortOrderInfo
        XCTAssertGreaterThan(sortOrderInfo.count, 0)

        let sortOrder = try XCTUnwrap(sortOrderInfo.first)
        XCTAssertNotNil(sortOrder.name)
        XCTAssertNotNil(sortOrder.precision)

        let extraStatsInfo = try XCTUnwrap(ranking.extraStatsInfo)
        XCTAssertGreaterThan(extraStatsInfo.count, 0)

        let extraStat = try XCTUnwrap(extraStatsInfo.first)
        XCTAssertNotNil(extraStat.name)
        XCTAssertNotNil(extraStat.precision)
    }

    func test_eventRankings_2015() async throws {
        let ranking = try await kit.eventRankings(key: "2015miket")

        let rankings = try XCTUnwrap(ranking.rankings)
        XCTAssertGreaterThan(rankings.count, 0)

        XCTAssertGreaterThan(ranking.sortOrderInfo.count, 0)

        let extraStatsInfo = try XCTUnwrap(ranking.extraStatsInfo)
        XCTAssertEqual(extraStatsInfo.count, 0)

        let rank = try XCTUnwrap(rankings.first)
        XCTAssertNil(rank.record)
        XCTAssertNotNil(rank.qualAverage)
    }

    func test_eventRankings_empty() async throws {
        let ranking = try await kit.eventRankings(key: "2018cars")
        XCTAssertNil(ranking.rankings)
        let extraStatsInfo = try XCTUnwrap(ranking.extraStatsInfo)
        XCTAssertEqual(extraStatsInfo.count, 0)
        XCTAssertGreaterThan(ranking.sortOrderInfo.count, 0)
    }

    func test_eventRankings_null() async throws {
        do {
            _ = try await kit.eventRankings(key: "1992cmp")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_eventTeams() async throws {
        let teams = try await kit.eventTeams(key: "2017mike2")
        XCTAssertGreaterThan(teams.count, 0)
    }

    func test_eventTeamStatuses() async throws {
        let statuses = try await kit.eventTeamStatuses(key: "2018misjo")
        XCTAssertGreaterThan(statuses.keys.count, 0)
    }

}
