import TBAKit
import XCTest

class TBATeamTests: TBAKitTestCase {

    func test_team_init() {
        let team = TBATeam(key: "frc7332", teamNumber: 7332, name: "Rawrbotz", rookieYear: 2012)
        XCTAssertEqual(team.key, "frc7332")
        XCTAssertEqual(team.teamNumber, 7332)
        XCTAssertEqual(team.name, "Rawrbotz")
        XCTAssertEqual(team.rookieYear, 2012)
    }

    func test_robot_init() {
        let robot = TBARobot(key: "frc7332_2012", name: "DorkX", teamKey: "frc7332", year: 2012)
        XCTAssertEqual(robot.key, "frc7332_2012")
        XCTAssertEqual(robot.name, "DorkX")
        XCTAssertEqual(robot.teamKey, "frc7332")
        XCTAssertEqual(robot.year, 2012)
    }

    func test_eventStatus_init() {
        let eventStatus = TBAEventStatus(teamKey: "frc7332", eventKey: "2018miket")
        XCTAssertEqual(eventStatus.teamKey, "frc7332")
        XCTAssertEqual(eventStatus.eventKey, "2018miket")
    }

    func test_eventStatusQual_init() {
        let eventStatusQual = TBAEventStatusQual()
        XCTAssertNotNil(eventStatusQual)
    }

    func test_eventStatusAlliance_int() {
        let eventStatusAlliance = TBAEventStatusAlliance(number: 7332, pick: 1)
        XCTAssertEqual(eventStatusAlliance.number, 7332)
        XCTAssertEqual(eventStatusAlliance.pick, 1)
    }

    func test_media_init() {
        let media = TBAMedia(type: "avatar", foreignKey: "key")
        XCTAssertEqual(media.type, "avatar")
    }

    func testTeams() {
        let ex = expectation(description: "teams_all")

        let task = kit.fetchTeams() { (result, notModified) in
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

    func testTeamsSimple() {
        let ex = expectation(description: "teams_all_simple")

        let task = kit.fetchTeams(simple: true) { (result, notModified) in
            let teams = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(teams.count, 0)
            let team = teams.first!

            XCTAssertNotNil(team.name)
            XCTAssertNil(team.website)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamsPage() {
        let ex = expectation(description: "teams_page")

        let task = kit.fetchTeams(page: 0) { (result, notModified) in
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

    func testTeamsPageEmpty() {
        let ex = expectation(description: "teams_page_empty")

        let task = kit.fetchTeams(page: 100) { (result, notModified) in
            let teams = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertEqual(teams.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamsYearPage() {
        let ex = expectation(description: "teams_year_page")

        let task = kit.fetchTeams(page: 0, year: 2017) { (result, notModified) in
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

    func testTeamsYearPageEmpty() {
        let ex = expectation(description: "teams_year_page_empty")

        let task = kit.fetchTeams(page: 100, year: 2017) { (result, notModified) in
            let teams = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertEqual(teams.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeam() {
        let ex = expectation(description: "team")

        let task = kit.fetchTeam(key: "frc2337") { (result, notModified) in
            let team = try! result.get()!
            XCTAssertFalse(notModified)

            XCTAssertNotNil(team.key)
            XCTAssertNotNil(team.name)
            XCTAssertNotNil(team.teamNumber)
            XCTAssertNotNil(team.rookieYear)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamEmpty() {
        let ex = expectation(description: "team_empty")

        let task = kit.fetchTeam(key: "frc13") { (result, notModified) in
            let team = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertNil(team)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamAwards() {
        let ex = expectation(description: "team_awards")

        let task = kit.fetchTeamAwards(key: "frc2337") { (result, notModified) in
            let awards = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(awards.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamAwardsYear() {
        let ex = expectation(description: "team_awards_year")

        let task = kit.fetchTeamAwards(key: "frc2337", year: 2017) { (result, notModified) in
            let awards = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(awards.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamDistricts() {
        let ex = expectation(description: "team_districts")

        let task = kit.fetchTeamDistricts(key: "frc2337") { (result, notModified) in
            let districts = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(districts.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamEventsYear() {
        let ex = expectation(description: "team_events_year")

        let task = kit.fetchTeamEvents(key: "frc2337", year: 2017) { (result, notModified) in
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

    func testTeamEventAwards() {
        let ex = expectation(description: "team_event_awards")

        let task = kit.fetchTeamAwards(key: "frc2337", eventKey: "2017mike2") { (result, notModified) in
            let awards = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(awards.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamEventMatches() {
        let ex = expectation(description: "team_event_matches")

        let task = kit.fetchTeamMatches(key: "frc2337", eventKey: "2017mike2") { (result, notModified) in
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

    func testTeamStatues() {
        let ex = expectation(description: "team_event_statuses")

        let task = kit.fetchTeamStatuses(key: "frc2337", year: 2018) { (result, notModified) in
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

    func testTeamEventStatus() {
        let ex = expectation(description: "team_event_status")

        let task = kit.fetchTeamStatus(key: "frc2337", eventKey: "2017mike2") { (result, notModified) in
            let status = try! result.get()!
            XCTAssertFalse(notModified)

            XCTAssertEqual(status.teamKey, "frc2337")
            XCTAssertEqual(status.eventKey, "2017mike2")

            let qual = status.qual!
            XCTAssertNotNil(qual.numTeams)
            XCTAssertNotNil(qual.status)
            XCTAssertNotNil(qual.ranking)
            XCTAssertNotNil(qual.sortOrder)
            let qualSortOrder = qual.sortOrder!
            XCTAssertGreaterThan(qualSortOrder.count, 0)

            let alliance = status.alliance!
            XCTAssertNotNil(alliance.number)
            XCTAssertNotNil(alliance.pick)

            XCTAssertNotNil(status.playoff)

            XCTAssertNotNil(status.allianceStatusString)
            XCTAssertNotNil(status.playoffStatusString)
            XCTAssertNotNil(status.overallStatusString)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamEventStatusNoElims() {
        let ex = expectation(description: "team_event_status_no_elims")

        let task = kit.fetchTeamStatus(key: "frc2337", eventKey: "2016micmp") { (result, notModified) in
            let status = try! result.get()!
            XCTAssertFalse(notModified)

            XCTAssertNotNil(status.qual)
            XCTAssertNil(status.alliance)
            XCTAssertNil(status.playoff)

            XCTAssertNotNil(status.allianceStatusString)
            XCTAssertNotNil(status.playoffStatusString)
            XCTAssertNotNil(status.overallStatusString)

            XCTAssertNotNil(status.lastMatchKey)
            XCTAssertNil(status.nextMatchKey)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamEventStatusEmpty() {
        let ex = expectation(description: "team_event_status_empty")

        let task = kit.fetchTeamStatus(key: "frc20", eventKey: "1992cmp") { (result, notModified) in
            let status = try! result.get()!
            XCTAssertFalse(notModified)

            XCTAssertNil(status.qual)
            XCTAssertNil(status.alliance)
            XCTAssertNil(status.playoff)

            XCTAssertNotNil(status.allianceStatusString)
            XCTAssertNotNil(status.playoffStatusString)
            XCTAssertNotNil(status.overallStatusString)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamMatchesYear() {
        let ex = expectation(description: "team_matches_year")

        let task = kit.fetchTeamMatches(key: "frc2337", year: 2017) { (result, notModified) in
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

    func testTeamMediaYear() {
        let ex = expectation(description: "team_media_year")

        let task = kit.fetchTeamMedia(key: "frc2337", year: 2017) { (result, notModified) in
            let media = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(media.count, 0)

            let m = media.first!
            XCTAssertNotNil(m.type)
            XCTAssertNotNil(m.foreignKey)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamRobots() {
        let ex = expectation(description: "team_robots")

        let task = kit.fetchTeamRobots(key: "frc2337") { (result, notModified) in
            let robots = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(robots.count, 0)

            let robot = robots.first!
            XCTAssertNotNil(robot.key)
            XCTAssertNotNil(robot.name)
            XCTAssertNotNil(robot.teamKey)
            XCTAssertNotNil(robot.year)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testSocialMedia() {
        let ex = expectation(description: "team_social_media")

        let task = kit.fetchTeamSocialMedia(key: "frc2337") { (result, notModified) in
            let socialMedia = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(socialMedia.count, 0)

            let media = socialMedia.first!
            XCTAssertNotNil(media.type)
            XCTAssertNotNil(media.foreignKey)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testYearsParticipated() {
        let ex = expectation(description: "team_years_participated")

        let task = kit.fetchTeamYearsParticipated(key: "frc2337") { (result, notModified) in
            let years = try! result.get()
            XCTAssertFalse(notModified)

            XCTAssertGreaterThan(years.count, 0)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

}
