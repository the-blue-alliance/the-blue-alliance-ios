import XCTest
import TBAKit

final class TBAKitTeamTests: TBAKitTestCase {

    func test_teams() async throws {
        let teams = try await kit.teams()
        XCTAssertGreaterThan(teams.count, 0)
    }

    func test_teams_simple() async throws {
        let teams = try await kit.teams(simple: true)
        XCTAssertGreaterThan(teams.count, 0)

        let team = try XCTUnwrap(teams.first)
        XCTAssertNotNil(team.name)
        XCTAssertNil(team.website)
    }

    func test_teams_page() async throws {
        let teams = try await kit.teams(page: 0)
        XCTAssertGreaterThan(teams.count, 0)
    }

    func test_teams_page_empty() async throws {
        let teams = try await kit.teams(page: 100)
        XCTAssertEqual(teams.count, 0)
    }

    func test_teams_year_page() async throws {
        let teams = try await kit.teams(page: 0, year: 2017)
        XCTAssertGreaterThan(teams.count, 0)
    }

    func test_teams_year_page_empty() async throws {
        let teams = try await kit.teams(page: 100, year: 2017)
        XCTAssertEqual(teams.count, 0)
    }

    func test_team() async throws {
        let team = try await kit.team(key: "frc2337")
        XCTAssertNotNil(team.key)
        XCTAssertNotNil(team.name)
        XCTAssertNotNil(team.teamNumber)
        XCTAssertNotNil(team.rookieYear)
    }

    func test_team_empty() async throws {
        let team = try await kit.team(key: "frc13")
        XCTAssertNotNil(team)
    }

    func test_teamAwards() async throws {
        let awards = try await kit.teamAwards(key: "frc2337")
        XCTAssertGreaterThan(awards.count, 0)
    }

    func test_teamAwards_year() async throws {
        let awards = try await kit.teamAwards(key: "frc2337", year: 2017)
        XCTAssertGreaterThan(awards.count, 0)
    }

    func test_teamDistricts() async throws {
        let districts = try await kit.teamDistricts(key: "frc2337")
        XCTAssertGreaterThan(districts.count, 0)
    }

    func test_teamEvents_year() async throws {
        let events = try await kit.teamEvents(key: "frc2337", year: 2017)
        XCTAssertGreaterThan(events.count, 0)
    }

    func test_teamAwards_event() async throws {
        let awards = try await kit.teamAwards(key: "frc2337", eventKey: "2017mike2")
        XCTAssertGreaterThan(awards.count, 0)
    }

    func test_teamMatches_event() async throws {
        let matches = try await kit.teamMatches(key: "frc2337", eventKey: "2017mike2")
        XCTAssertGreaterThan(matches.count, 0)
    }

    func test_teamStatuses() async throws {
        let statuses = try await kit.teamStatuses(key: "frc2337", year: 2018)
        XCTAssertGreaterThan(statuses.keys.count, 0)
    }

    func test_teamStatus_event() async throws {
        let status = try await kit.teamStatus(key: "frc2337", eventKey: "2017mike2")

        let qual = try XCTUnwrap(status.qual)
        XCTAssertNotNil(qual.numTeams)
        XCTAssertNotNil(qual.status)
        XCTAssertNotNil(qual.ranking)

        let qualSortOrder = try XCTUnwrap(qual.sortOrderInfo)
        XCTAssertGreaterThan(qualSortOrder.count, 0)

        let alliance = try XCTUnwrap(status.alliance)
        XCTAssertNotNil(alliance.number)
        XCTAssertNotNil(alliance.pick)

        XCTAssertNotNil(status.playoff)

        XCTAssertNotNil(status.allianceStatusString)
        XCTAssertNotNil(status.playoffStatusString)
        XCTAssertNotNil(status.overallStatusString)
    }

    func test_teamEventStatus_noElims() async throws {
        let status = try await kit.teamStatus(key: "frc2337", eventKey: "2016micmp")
        XCTAssertNotNil(status.qual)
        XCTAssertNil(status.alliance)
        XCTAssertNil(status.playoff)

        XCTAssertNotNil(status.allianceStatusString)
        XCTAssertNotNil(status.playoffStatusString)
        XCTAssertNotNil(status.overallStatusString)

        XCTAssertNotNil(status.lastMatchKey)
        XCTAssertNil(status.nextMatchKey)
    }

    func test_teamEventStatus_empty() async throws {
        let status = try await kit.teamStatus(key: "frc20", eventKey: "1992cmp")
        XCTAssertNil(status.qual)
        XCTAssertNil(status.alliance)
        XCTAssertNil(status.playoff)

        XCTAssertNotNil(status.allianceStatusString)
        XCTAssertNotNil(status.playoffStatusString)
        XCTAssertNotNil(status.overallStatusString)
    }

    func test_teamMatches_year() async throws {
        let matches = try await kit.teamMatches(key: "frc2337", year: 2017)
        XCTAssertGreaterThan(matches.count, 0)
    }

    func test_teamMedia_year() async throws {
        let media = try await kit.teamMedia(key: "frc2337", year: 2017)
        XCTAssertGreaterThan(media.count, 0)
    }

    func test_teamRobots() async throws {
        let robots = try await kit.teamRobots(key: "frc2337")
        XCTAssertGreaterThan(robots.count, 0)
    }

    func test_teamSocialMedia() async throws {
        let media = try await kit.teamSocialMedia(key: "frc2337")
        XCTAssertGreaterThan(media.count, 0)
    }

    func test_teamYearsParticipated() async throws {
        let years = try await kit.teamYearsParticipated(key: "frc2337")
        XCTAssertGreaterThan(years.count, 0)
    }

}
