import TBAKit
import XCTest

class TBAEventTests: TBAKitTestCase {

    func test_event_init() {
        let startDate = Date(timeIntervalSince1970: 1519866000)
        let endDate = Date(timeIntervalSince1970: 1520038800)

        let event = TBAEvent(key: "2018miket", name: "Kettering District", eventCode: "miket", eventType: 1, startDate: startDate, endDate: endDate, year: 2018, eventTypeString: "District", divisionKeys: [])

        XCTAssertEqual(event.key, "2018miket")
        XCTAssertEqual(event.name, "Kettering District")
        XCTAssertEqual(event.eventCode, "miket")
        XCTAssertEqual(event.eventType, 1)
        XCTAssertEqual(event.startDate, startDate)
        XCTAssertEqual(event.endDate, endDate)
        XCTAssertEqual(event.year, 2018)
        XCTAssertEqual(event.eventTypeString, "District")
        XCTAssertEqual(event.divisionKeys, [])
    }

    func test_alliance_init() {
        let alliance = TBAAlliance(picks: ["frc7332"])
        XCTAssertEqual(alliance.picks, ["frc7332"])
    }

    func test_allianceBackup_init() {
        let backup = TBAAllianceBackup(teamIn: "frc7332", teamOut: "frc2337")
        XCTAssertEqual(backup.teamIn, "frc7332")
        XCTAssertEqual(backup.teamOut, "frc2337")
    }

    func test_allianceStatus_init() {
        let status = TBAAllianceStatus()
        XCTAssertNotNil(status)
    }

    func test_wlt_init() {
        let wlt = TBAWLT(wins: 1, losses: 2, ties: 3)
        XCTAssertEqual(wlt.wins, 1)
        XCTAssertEqual(wlt.losses, 2)
        XCTAssertEqual(wlt.ties, 3)
    }

    func test_award_init() {
        let awardName = "The Fake Award, sponsored by Dunder Mifflin Paper Company"
        let award = TBAAward(name: awardName, awardType: 1, eventKey: "2018miket", recipients: [], year: 2018)

        XCTAssertEqual(award.name, awardName)
        XCTAssertEqual(award.awardType, 1)
        XCTAssertEqual(award.eventKey, "2018miket")
        XCTAssertEqual(award.recipients, [])
        XCTAssertEqual(award.year, 2018)
    }

    func test_awardRecipient_init() {
        let teamAward = TBAAwardRecipient(teamKey: "frc7332")
        XCTAssertEqual(teamAward.teamKey, "frc7332")
        XCTAssertNil(teamAward.awardee)

        let humanAward = TBAAwardRecipient(awardee: "Zachary Orr")
        XCTAssertEqual(humanAward.awardee, "Zachary Orr")
        XCTAssertNil(humanAward.teamKey)
    }

    func test_eventRanking_init() {
        let eventRanking = TBAEventRanking(teamKey: "frc7332", rank: 2)
        XCTAssertEqual(eventRanking.teamKey, "frc7332")
        XCTAssertEqual(eventRanking.rank, 2)
    }

    func test_eventRankingSortOrder_init() {
        let sortOrder = TBAEventRankingSortOrder(name: "Auto Climb", precision: 3)
        XCTAssertEqual(sortOrder.name, "Auto Climb")
        XCTAssertEqual(sortOrder.precision, 3)
    }

    func test_insights_init() {
        let insights = TBAEventInsights()
        XCTAssertNotNil(insights)
    }

    func test_stat_init() {
        let stat = TBAStat(teamKey: "frc7332", ccwm: 2.2, dpr: 3.3, opr: 4.4)
        XCTAssertEqual(stat.teamKey, "frc7332")
        XCTAssertEqual(stat.ccwm, 2.2)
        XCTAssertEqual(stat.dpr, 3.3)
        XCTAssertEqual(stat.opr, 4.4)
    }

    func test_webcast_init() {
        let webcast = TBAWebcast(type: "type", channel: "channel")
        XCTAssertEqual(webcast.type, "type")
        XCTAssertEqual(webcast.channel, "channel")
    }

    func testEvents() {
        let ex = expectation(description: "events_all")

        let task = kit.fetchEvents() { (result, notModified) in
            let events = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(events.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventsYear() {
        let ex = expectation(description: "events_year")

        let task = kit.fetchEvents(year: 2017) { (result, notModified) in
            let events = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(events.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEvent() {
        let ex = expectation(description: "event")

        let task = kit.fetchEvent(key: "2017mike2") { (result, notModified) in
            let event = try! result.get()!
            XCTAssertFalse(notModified)

            XCTAssertNotNil(event.key)
            XCTAssertNotNil(event.eventCode)
            XCTAssertNotNil(event.name)
            XCTAssertNotNil(event.startDate)
            XCTAssertNotNil(event.endDate)
            XCTAssertNotNil(event.year)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testParentEvent() {
        let parentEventKey = "2017micmp"
        let childEventKey = "2017micmp3"

        let parentEx = expectation(description: "event_parent")
        let parentTask = kit.fetchEvent(key: parentEventKey) { (result, notModified) in
            let event = try! result.get()!
            XCTAssertFalse(notModified)

            XCTAssertNotNil(event.divisionKeys)
            XCTAssertTrue(event.divisionKeys.contains(childEventKey))

            parentEx.fulfill()
        }
        kit.sendSuccessStub(for: parentTask)

        let childEx = expectation(description: "event_child")
        let childTask = kit.fetchEvent(key: childEventKey) { (result, notModified) in
            let event = try! result.get()!
            XCTAssertFalse(notModified)

            XCTAssertNotNil(event.parentEventKey)
            XCTAssertEqual(event.parentEventKey, parentEventKey)

            childEx.fulfill()
        }
        kit.sendSuccessStub(for: childTask)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventAlliances() {
        let ex = expectation(description: "event_alliances")

        let task = kit.fetchEventAlliances(key: "2017mike2") { (result, notModified) in
            let alliances = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(alliances.count, 0)

            let alliance = alliances.first!
            XCTAssertNotNil(alliance.picks)
            XCTAssertGreaterThan(alliance.picks.count, 0)
            XCTAssertNotNil(alliance.declines)
            XCTAssertNotNil(alliance.status)

            let status = alliance.status!
            XCTAssertNotNil(status.currentRecord)
            XCTAssertNotNil(status.level)
            XCTAssertNotNil(status.record)
            XCTAssertNotNil(status.status)

            let record = status.record!
            XCTAssertNotNil(record.wins)
            XCTAssertNotNil(record.losses)
            XCTAssertNotNil(record.ties)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventAlliancesBackup() {
        let ex = expectation(description: "event_alliances_backup")

        let task = kit.fetchEventAlliances(key: "2018micmp4") { (result, notModified) in
            let alliances = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(alliances.count, 0)

            XCTAssertNil(alliances.first!.backup)

            // backup is on the second alliance
            let alliance = alliances[1]
            XCTAssertNotNil(alliance.backup)
            XCTAssertNotNil(alliance.backup?.teamIn)
            XCTAssertNotNil(alliance.backup?.teamOut)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventAlliancesPlayoffAverage() {
        let ex = expectation(description: "event_alliances_playoff_average")

        let task = kit.fetchEventAlliances(key: "2015mike2") { (result, notModified) in
            let alliances = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(alliances.count, 0)

            let alliance = alliances.first!
            XCTAssertNotNil(alliance.status)

            let status = alliance.status!
            XCTAssertNotNil(status.playoffAverage)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventAwards() {
        let ex = expectation(description: "event_awards")

        let task = kit.fetchEventAwards(key: "2017mike2") { (result, notModified) in
            let awards = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(awards.count, 0)

            let award = awards.first!
            XCTAssertNotNil(award.awardType)
            XCTAssertNotNil(award.eventKey)
            XCTAssertNotNil(award.name)
            XCTAssertNotNil(award.awardType)
            XCTAssertNotNil(award.year)
            XCTAssertNotNil(award.recipients)
            XCTAssertGreaterThan(award.recipients.count, 0)

            let recipient = award.recipients.first!
            XCTAssertNotNil(recipient.teamKey)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventAwardsAwardee() {
        let ex = expectation(description: "event_awards_awardee")

        let task = kit.fetchEventAwards(key: "2015micmp") { (result, notModified) in
            let awards = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(awards.count, 0)

            guard let deansListAwardIndex = awards.firstIndex(where: { $0.awardType == 4 }) else {
                XCTFail()
                return
            }

            let deansListAward = awards[deansListAwardIndex]
            let recipient = deansListAward.recipients.first!
            XCTAssertNotNil(recipient.teamKey)
            XCTAssertNotNil(recipient.awardee)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventDistrictPoints() {
        let ex = expectation(description: "event_district_points")

        let task = kit.fetchEventDistrictPoints(key: "2017mike2") { (result, notModified) in
            let (districtPoints, tiebreakers) = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(districtPoints.count, 0)

            let districtPoint = districtPoints.first!
            XCTAssertNotNil(districtPoint.teamKey)
            XCTAssertNotNil(districtPoint.eventKey)
            XCTAssertNotNil(districtPoint.alliancePoints)
            XCTAssertNotNil(districtPoint.awardPoints)
            XCTAssertNotNil(districtPoint.elimPoints)
            XCTAssertNotNil(districtPoint.qualPoints)
            XCTAssertNotNil(districtPoint.total)

            XCTAssertNotNil(tiebreakers)
            XCTAssertGreaterThan(tiebreakers.count, 0)

            let tiebreaker = tiebreakers.first!
            XCTAssertNotNil(tiebreaker.teamKey)
            XCTAssertNotNil(tiebreaker.qualWins)
            XCTAssertNotNil(tiebreaker.highestQualScores)
            XCTAssertGreaterThan(tiebreaker.highestQualScores.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventDistrictPointsRegional() {
        let ex = expectation(description: "event_district_points_regional")

        let task = kit.fetchEventDistrictPoints(key: "2005ga") { (result, notModified) in
            do {
                _ = try result.get()
                XCTFail()
            } catch {
                XCTAssertNotNil(error)
            }
            XCTAssertFalse(notModified)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventInsights() {
        let ex = expectation(description: "event_insights")

        let task = kit.fetchEventInsights(key: "2017mike2") { (result, notModified) in
            let insights = try! result.get()!
            XCTAssertFalse(notModified)

            XCTAssertNotNil(insights.qual)
            XCTAssertNotNil(insights.playoff)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventInsightsNull() {
        let ex = expectation(description: "event_insights_null")

        let task = kit.fetchEventInsights(key: "2015miket") { (result, notModified) in
            do {
                _ = try result.get()
                XCTFail()
            } catch {
                XCTAssertNotNil(error)
            }
            XCTAssertFalse(notModified)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventMatches() {
        let ex = expectation(description: "event_matches")

        let task = kit.fetchEventMatches(key: "2017mike2") { (result, notModified) in
            let matches = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(matches.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventOPRs() {
        let ex = expectation(description: "event_oprs")

        let task = kit.fetchEventTeamStats(key: "2017mike2") { (result, notModified) in
            let stats = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(stats.count, 0)

            let stat = stats.first!
            XCTAssertNotNil(stat.teamKey)
            XCTAssertNotNil(stat.opr)
            XCTAssertNotNil(stat.dpr)
            XCTAssertNotNil(stat.ccwm)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventOPRsNull() {
        let ex = expectation(description: "event_oprs_null")

        let task = kit.fetchEventTeamStats(key: "1992cmp") { (result, notModified) in
            do {
                _ = try result.get()
                XCTFail()
            } catch {
                XCTAssertNotNil(error)
            }
            XCTAssertFalse(notModified)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventRankings() {
        let ex = expectation(description: "event_rankings")

        let task = kit.fetchEventRankings(key: "2017mike2") { (result, notModified) in
            let (rankings, sortOrderInfo, extraStatsInfo) = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(rankings.count, 0)

            let ranking = rankings.first!
            XCTAssertNotNil(ranking.teamKey)
            XCTAssertNotNil(ranking.rank)
            XCTAssertNotNil(ranking.record)
            XCTAssertNotNil(ranking.sortOrders)
            XCTAssertNotNil(ranking.extraStats)

            XCTAssertNotNil(sortOrderInfo)
            XCTAssertGreaterThan(sortOrderInfo.count, 0)

            let sortOrder = sortOrderInfo.first!
            XCTAssertNotNil(sortOrder.name)
            XCTAssertNotNil(sortOrder.precision)

            XCTAssertNotNil(extraStatsInfo)
            XCTAssertGreaterThan(extraStatsInfo.count, 0)

            let extraStat = extraStatsInfo.first!
            XCTAssertNotNil(extraStat.name)
            XCTAssertNotNil(extraStat.precision)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventRankings2015() {
        let ex = expectation(description: "event_rankings_2015")

        let task = kit.fetchEventRankings(key: "2015miket") { (result, notModified) in
            let (rankings, sortOrderInfo, extraStatsInfo) = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(rankings.count, 0)
            XCTAssertGreaterThan(sortOrderInfo.count, 0)
            XCTAssertEqual(extraStatsInfo.count, 0)

            let ranking = rankings.first!
            XCTAssertNil(ranking.record)
            XCTAssertNotNil(ranking.qualAverage)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventRankingsEmpty() {
        let ex = expectation(description: "event_rankings_empty")

        let task = kit.fetchEventRankings(key: "2018cars") { (result, notModified) in
            let (rankings, sortOrderInfo, extraStatsInfo) = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertEqual(rankings.count, 0)
            XCTAssertEqual(extraStatsInfo.count, 0)
            XCTAssertGreaterThan(sortOrderInfo.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventRankingsNull() {
        let ex = expectation(description: "event_rankings_null")

        let task = kit.fetchEventRankings(key: "1992cmp") { (result, notModified) in
            do {
                _ = try result.get()
                XCTFail()
            } catch {
                XCTAssertNotNil(error)
            }
            XCTAssertFalse(notModified)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventTeams() {
        let ex = expectation(description: "event_teams")

        let task = kit.fetchEventTeams(key: "2017mike2") { (result, notModified) in
            let teams = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(teams.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventTeamStatuses() {
        let ex = expectation(description: "event_team_statuses")

        let task = kit.fetchEventStatuses(key: "2018misjo") { (result, notModified) in
            let statuses = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(statuses.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

}
