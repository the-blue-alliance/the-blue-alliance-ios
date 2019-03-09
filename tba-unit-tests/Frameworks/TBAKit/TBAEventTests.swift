import XCTest
@testable import TBA

class TBAEventTests: TBAKitTestCase {

    func test_event_init() {
        let startDate = Event.dateFormatter.date(from: "2018-03-01")!
        let endDate = Event.dateFormatter.date(from: "2018-03-03")!

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

    func testEventsYear() {
        let ex = expectation(description: "events_year")
        
        let task = kit.fetchEvents(year: 2017) { (events, error) in
            XCTAssertNotNil(events)
            XCTAssertGreaterThan(events!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEvent() {
        let ex = expectation(description: "event")
        
        let task = kit.fetchEvent(key: "2017mike2") { (event, error) in
            XCTAssertNotNil(event)
            XCTAssertNotNil(event?.key)
            XCTAssertNotNil(event?.eventCode)
            XCTAssertNotNil(event?.name)
            XCTAssertNotNil(event?.startDate)
            XCTAssertNotNil(event?.endDate)
            XCTAssertNotNil(event?.year)
            
            XCTAssertNil(error)
            
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
        let parentTask = kit.fetchEvent(key: parentEventKey) { (event, error) in
            XCTAssertNotNil(event)
            XCTAssertNotNil(event?.divisionKeys)
            XCTAssertTrue(event!.divisionKeys.contains(childEventKey))
            
            XCTAssertNil(error)
            
            parentEx.fulfill()
        }
        kit.sendSuccessStub(for: parentTask)
        
        let childEx = expectation(description: "event_child")
        let childTask = kit.fetchEvent(key: childEventKey) { (event, error) in
            XCTAssertNotNil(event)
            XCTAssertNotNil(event?.parentEventKey)
            XCTAssertEqual(event!.parentEventKey, parentEventKey)
            
            XCTAssertNil(error)
            
            childEx.fulfill()
        }
        kit.sendSuccessStub(for: childTask)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventAlliances() {
        let ex = expectation(description: "event_alliances")
        
        let task = kit.fetchEventAlliances(key: "2017mike2") { (alliances, error) in
            XCTAssertNotNil(alliances)
            XCTAssertGreaterThan(alliances!.count, 0)
            
            let alliance = alliances!.first!
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

            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventAlliancesBackup() {
        let ex = expectation(description: "event_alliances_backup")
        
        let task = kit.fetchEventAlliances(key: "2018micmp4") { (alliances, error) in
            XCTAssertNotNil(alliances)
            XCTAssertGreaterThan(alliances!.count, 0)
            
            XCTAssertNil(alliances?.first!.backup)
            
            // backup is on the second alliance
            let alliance = alliances![1]
            XCTAssertNotNil(alliance.backup)
            XCTAssertNotNil(alliance.backup?.teamIn)
            XCTAssertNotNil(alliance.backup?.teamOut)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventAlliancesPlayoffAverage() {
        let ex = expectation(description: "event_alliances_playoff_average")
        
        let task = kit.fetchEventAlliances(key: "2015mike2") { (alliances, error) in
            XCTAssertNotNil(alliances)
            XCTAssertGreaterThan(alliances!.count, 0)
            
            let alliance = alliances!.first!
            XCTAssertNotNil(alliance.status)
            
            let status = alliance.status!
            XCTAssertNotNil(status.playoffAverage)

            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventAwards() {
        let ex = expectation(description: "event_awards")
        
        let task = kit.fetchEventAwards(key: "2017mike2") { (awards, error) in
            XCTAssertNotNil(awards)
            XCTAssertGreaterThan(awards!.count, 0)

            let award = awards!.first!
            XCTAssertNotNil(award.awardType)
            XCTAssertNotNil(award.eventKey)
            XCTAssertNotNil(award.name)
            XCTAssertNotNil(award.awardType)
            XCTAssertNotNil(award.year)
            XCTAssertNotNil(award.recipients)
            XCTAssertGreaterThan(award.recipients.count, 0)
            
            let recipient = award.recipients.first!
            XCTAssertNotNil(recipient.teamKey)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventAwardsAwardee() {
        let ex = expectation(description: "event_awards_awardee")
        
        let task = kit.fetchEventAwards(key: "2015micmp") { (awards, error) in
            XCTAssertNotNil(awards)
            XCTAssertGreaterThan(awards!.count, 0)
            
            guard let deansListAwardIndex = awards?.index(where: { $0.awardType == 4 }), let deansListAward = awards?[deansListAwardIndex] else {
                XCTFail()
                return
            }
            
            let recipient = deansListAward.recipients.first!
            XCTAssertNotNil(recipient.teamKey)
            XCTAssertNotNil(recipient.awardee)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventDistrictPoints() {
        let ex = expectation(description: "event_district_points")
        
        let task = kit.fetchEventDistrictPoints(key: "2017mike2") { (districtPoints, tiebreakers, error) in
            XCTAssertNotNil(districtPoints)
            XCTAssertGreaterThan(districtPoints!.count, 0)

            let districtPoint = districtPoints!.first!
            XCTAssertNotNil(districtPoint.teamKey)
            XCTAssertNotNil(districtPoint.eventKey)
            XCTAssertNotNil(districtPoint.alliancePoints)
            XCTAssertNotNil(districtPoint.awardPoints)
            XCTAssertNotNil(districtPoint.elimPoints)
            XCTAssertNotNil(districtPoint.qualPoints)
            XCTAssertNotNil(districtPoint.total)
            
            XCTAssertNotNil(tiebreakers)
            XCTAssertGreaterThan(tiebreakers!.count, 0)

            let tiebreaker = tiebreakers!.first!
            XCTAssertNotNil(tiebreaker.teamKey)
            XCTAssertNotNil(tiebreaker.qualWins)
            XCTAssertNotNil(tiebreaker.highestQualScores)
            XCTAssertGreaterThan(tiebreaker.highestQualScores.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventDistrictPointsRegional() {
        let ex = expectation(description: "event_district_points_regional")
        
        let task = kit.fetchEventDistrictPoints(key: "2005ga") { (districtPoints, tiebreakers, error) in
            XCTAssertNil(districtPoints)
            XCTAssertNil(tiebreakers)
            
            XCTAssertNotNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventInsights() {
        let ex = expectation(description: "event_insights")
        
        let task = kit.fetchEventInsights(key: "2017mike2") { (insights, error) in
            XCTAssertNotNil(insights)

            XCTAssertNotNil(insights?.qual)
            XCTAssertNotNil(insights?.playoff)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventInsightsNull() {
        let ex = expectation(description: "event_insights_null")
        
        let task = kit.fetchEventInsights(key: "2015miket") { (insights, error) in
            XCTAssertNil(insights)
            XCTAssertNil(error)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventMatches() {
        let ex = expectation(description: "event_matches")
        
        let task = kit.fetchEventMatches(key: "2017mike2") { (matches, error) in
            XCTAssertNotNil(matches)
            XCTAssertGreaterThan(matches!.count, 0)

            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventOPRs() {
        let ex = expectation(description: "event_oprs")
        
        let task = kit.fetchEventTeamStats(key: "2017mike2") { (stats, error) in
            XCTAssertNotNil(stats)
            XCTAssertGreaterThan(stats!.count, 0)
            
            let stat = stats!.first!
            XCTAssertNotNil(stat.teamKey)
            XCTAssertNotNil(stat.opr)
            XCTAssertNotNil(stat.dpr)
            XCTAssertNotNil(stat.ccwm)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventOPRsNull() {
        let ex = expectation(description: "event_oprs_null")
        
        let task = kit.fetchEventTeamStats(key: "1992cmp") { (stats, error) in
            XCTAssertNil(stats)
            XCTAssertNotNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventPredictions() {
        let ex = expectation(description: "event_predictions")
        
        let task = kit.fetchEventPredictions(key: "2017mike2") { (predictions, error) in
            XCTAssertNotNil(predictions)
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventPredictionsNull() {
        let ex = expectation(description: "event_predictions_null")
        
        let task = kit.fetchEventPredictions(key: "2009gg") { (predictions, error) in
            XCTAssertNil(predictions)
            XCTAssertNotNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventRankings() {
        let ex = expectation(description: "event_rankings")
        
        let task = kit.fetchEventRankings(key: "2017mike2") { (rankings, sortOrderInfo, extraStatsInfo, error) in
            XCTAssertNotNil(rankings)
            XCTAssertGreaterThan(rankings!.count, 0)

            let ranking = rankings!.first!
            XCTAssertNotNil(ranking.teamKey)
            XCTAssertNotNil(ranking.rank)
            XCTAssertNotNil(ranking.record)
            XCTAssertNotNil(ranking.sortOrders)
            XCTAssertNotNil(ranking.extraStats)
            
            XCTAssertNotNil(sortOrderInfo)
            XCTAssertGreaterThan(sortOrderInfo!.count, 0)
            
            let sortOrder = sortOrderInfo!.first!
            XCTAssertNotNil(sortOrder.name)
            XCTAssertNotNil(sortOrder.precision)
            
            XCTAssertNotNil(extraStatsInfo)
            XCTAssertGreaterThan(extraStatsInfo!.count, 0)

            let extraStat = extraStatsInfo!.first!
            XCTAssertNotNil(extraStat.name)
            XCTAssertNotNil(extraStat.precision)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testEventRankings2015() {
        let ex = expectation(description: "event_rankings_2015")
        
        let task = kit.fetchEventRankings(key: "2015miket") { (rankings, sortOrderInfo, extraStatsInfo, error) in
            XCTAssertNotNil(rankings)
            XCTAssertGreaterThan(rankings!.count, 0)
            
            let ranking = rankings!.first!
            XCTAssertNil(ranking.record)
            XCTAssertNotNil(ranking.qualAverage)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventRankingsEmpty() {
        let ex = expectation(description: "event_rankings_empty")
        
        let task = kit.fetchEventRankings(key: "2018cars") { (rankings, sortOrderInfo, extraStatsInfo, error) in
            XCTAssertNotNil(rankings)
            XCTAssertEqual(rankings!.count, 0)
            
            XCTAssertNotNil(extraStatsInfo)
            XCTAssertEqual(extraStatsInfo!.count, 0)

            XCTAssertNotNil(sortOrderInfo)
            XCTAssertGreaterThan(sortOrderInfo!.count, 0)

            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventRankingsNull() {
        let ex = expectation(description: "event_rankings_null")
        
        let task = kit.fetchEventRankings(key: "1992cmp") { (rankings, sortOrderInfo, extraStatsInfo, error) in
            XCTAssertNil(rankings)
            XCTAssertNil(rankings)
            XCTAssertNil(rankings)
            
            XCTAssertNotNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventTeams() {
        let ex = expectation(description: "event_teams")
        
        let task = kit.fetchEventTeams(key: "2017mike2") { (teams, error) in
            XCTAssertNotNil(teams)
            XCTAssertGreaterThan(teams!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventTeamStatuses() {
        let ex = expectation(description: "event_team_statuses")
        
        let task = kit.fetchEventStatuses(key: "2018misjo") { (statuses, error) in
            XCTAssertNotNil(statuses)
            XCTAssertGreaterThan(statuses!.count, 0)
            
            XCTAssertNil(error)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventMatchesTimeseries() {
        let ex = expectation(description: "event_match_timeseries")
        
        let task = kit.fetchEventMatchesTimeseries(key: "2018carv") { (timeseriesMatches, error) in
            XCTAssertNotNil(timeseriesMatches)
            XCTAssertGreaterThan(timeseriesMatches!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testEventMatchesTimeseriesEmpty() {
        let ex = expectation(description: "event_match_timeseries_empty")
        
        let task = kit.fetchEventMatchesTimeseries(key: "2018misjo") { (timeseriesMatches, error) in
            XCTAssertNotNil(timeseriesMatches)
            XCTAssertEqual(timeseriesMatches!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
}
