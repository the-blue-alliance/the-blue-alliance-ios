import XCTest
@testable import TBA

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
        let media = TBAMedia(type: "avatar")
        XCTAssertEqual(media.type, "avatar")
    }

    func testTeamsPage() {
        let ex = expectation(description: "teams_page")
        
        let task = kit.fetchTeams(page: 0) { (teams, error) in
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
    
    func testTeamsPageEmpty() {
        let ex = expectation(description: "teams_page_empty")
        
        let task = kit.fetchTeams(page: 100) { (teams, error) in
            XCTAssertNotNil(teams)
            XCTAssertEqual(teams!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamsYearPage() {
        let ex = expectation(description: "teams_year_page")
        
        let task = kit.fetchTeams(page: 0, year: 2017) { (teams, error) in
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
    
    func testTeamsYearPageEmpty() {
        let ex = expectation(description: "teams_year_page_empty")
        
        let task = kit.fetchTeams(page: 100, year: 2017) { (teams, error) in
            XCTAssertNotNil(teams)
            XCTAssertEqual(teams!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeam() {
        let ex = expectation(description: "team")

        let task = kit.fetchTeam(key: "frc2337") { (team, error) in
            XCTAssertNotNil(team)
            XCTAssertNotNil(team?.key)
            XCTAssertNotNil(team?.name)
            XCTAssertNotNil(team?.teamNumber)
            XCTAssertNotNil(team?.rookieYear)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamEmpty() {
        let ex = expectation(description: "team_empty")
        
        let task = kit.fetchTeam(key: "frc13") { (team, error) in
            XCTAssertNil(team)
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamAwards() {
        let ex = expectation(description: "team_awards")

        let task = kit.fetchTeamAwards(key: "frc2337") { (awards, error) in
            XCTAssertNotNil(awards)
            XCTAssertGreaterThan(awards!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamAwardsYear() {
        let ex = expectation(description: "team_awards_year")
        
        let task = kit.fetchTeamAwards(key: "frc2337", year: 2017) { (awards, error) in
            XCTAssertNotNil(awards)
            XCTAssertGreaterThan(awards!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamDistricts() {
        let ex = expectation(description: "team_districts")
        
        let task = kit.fetchTeamDistricts(key: "frc2337") { (districts, error) in
            XCTAssertNotNil(districts)
            XCTAssertGreaterThan(districts!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamEventsYear() {
        let ex = expectation(description: "team_events_year")
        
        let task = kit.fetchTeamEvents(key: "frc2337", year: 2017) { (events, error) in
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
    
    func testTeamEventAwards() {
        let ex = expectation(description: "team_event_awards")
        
        let task = kit.fetchTeamAwards(key: "frc2337", eventKey: "2017mike2") { (awards, error) in
            XCTAssertNotNil(awards)
            XCTAssertGreaterThan(awards!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamEventMatches() {
        let ex = expectation(description: "team_event_matches")
        
        let task = kit.fetchTeamMatches(key: "frc2337", eventKey: "2017mike2") { (matches, error) in
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
    
    func testTeamStatues() {
        let ex = expectation(description: "team_event_statuses")
        
        let task = kit.fetchTeamStatuses(key: "frc2337", year: 2018) { (statuses, error) in
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
    
    func testTeamEventStatus() {
        let ex = expectation(description: "team_event_status")
        
        let task = kit.fetchTeamStatus(key: "frc2337", eventKey: "2017mike2") { (status, error) in
            XCTAssertNotNil(status)

            XCTAssertEqual(status?.teamKey, "frc2337")
            XCTAssertEqual(status?.eventKey, "2017mike2")

            XCTAssertNotNil(status?.qual)
            XCTAssertNotNil(status?.qual?.numTeams)
            XCTAssertNotNil(status?.qual?.status)
            XCTAssertNotNil(status?.qual?.ranking)
            XCTAssertNotNil(status?.qual?.sortOrder)
            XCTAssertGreaterThan(status!.qual!.sortOrder!.count, 0)
            
            XCTAssertNotNil(status?.alliance)
            XCTAssertNotNil(status?.alliance?.number)
            XCTAssertNotNil(status?.alliance?.pick)

            XCTAssertNotNil(status?.playoff)
            
            XCTAssertNotNil(status?.allianceStatusString)
            XCTAssertNotNil(status?.playoffStatusString)
            XCTAssertNotNil(status?.overallStatusString)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamEventStatusNoElims() {
        let ex = expectation(description: "team_event_status_no_elims")
        
        let task = kit.fetchTeamStatus(key: "frc2337", eventKey: "2016micmp") { (status, error) in
            XCTAssertNotNil(status)
            
            XCTAssertNotNil(status?.qual)
            XCTAssertNil(status?.alliance)
            XCTAssertNil(status?.playoff)
            
            XCTAssertNotNil(status?.allianceStatusString)
            XCTAssertNotNil(status?.playoffStatusString)
            XCTAssertNotNil(status?.overallStatusString)
            
            XCTAssertNotNil(status?.lastMatchKey)
            XCTAssertNil(status?.nextMatchKey)

            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamEventStatusEmpty() {
        let ex = expectation(description: "team_event_status_empty")
        
        let task = kit.fetchTeamStatus(key: "frc20", eventKey: "1992cmp") { (status, error) in
            XCTAssertNotNil(status)
            
            XCTAssertNil(status?.qual)
            XCTAssertNil(status?.alliance)
            XCTAssertNil(status?.playoff)
            
            XCTAssertNotNil(status?.allianceStatusString)
            XCTAssertNotNil(status?.playoffStatusString)
            XCTAssertNotNil(status?.overallStatusString)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTeamMatchesYear() {
        let ex = expectation(description: "team_matches_year")
        
        let task = kit.fetchTeamMatches(key: "frc2337", year: 2017) { (matches, error) in
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
    
    func testTeamMediaYear() {
        let ex = expectation(description: "team_media_year")
        
        let task = kit.fetchTeamMedia(key: "frc2337", year: 2017) { (media, error) in
            XCTAssertNotNil(media)
            XCTAssertGreaterThan(media!.count, 0)
            
            let m = media!.first!
            XCTAssertNotNil(m.type)
            XCTAssertNotNil(m.foreignKey)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testTeamRobots() {
        let ex = expectation(description: "team_robots")
        
        let task = kit.fetchTeamRobots(key: "frc2337") { (robots, error) in
            XCTAssertNotNil(robots)
            XCTAssertGreaterThan(robots!.count, 0)
            
            let robot = robots!.first!
            XCTAssertNotNil(robot.key)
            XCTAssertNotNil(robot.name)
            XCTAssertNotNil(robot.teamKey)
            XCTAssertNotNil(robot.year)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testSocialMedia() {
        let ex = expectation(description: "team_social_media")
        
        let task = kit.fetchTeamSocialMedia(key: "frc2337") { (socialMedia, error) in
            XCTAssertNotNil(socialMedia)
            XCTAssertGreaterThan(socialMedia!.count, 0)
            
            let media = socialMedia!.first!
            XCTAssertNotNil(media.type)
            XCTAssertNotNil(media.foreignKey)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testYearsParticipated() {
        let ex = expectation(description: "team_years_participated")
        
        let task = kit.fetchTeamYearsParticipated(key: "frc2337") { (years, error) in
            XCTAssertNotNil(years)
            XCTAssertGreaterThan(years!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
}
