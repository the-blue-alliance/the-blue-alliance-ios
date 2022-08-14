import XCTest
import TBAKit

final class TBAKitDistrictTests: TBAKitTestCase {

    func test_districtsYear() async throws {
        let districts = try await kit.districts(year: 2017)
        XCTAssertGreaterThan(districts.count, 0)

        let district = try XCTUnwrap(districts.first)
        XCTAssertNotNil(district.abbreviation)
        XCTAssertNotNil(district.name)
        XCTAssertNotNil(district.key)
        XCTAssertNotNil(district.year)
    }

    func test_districtEvents() async throws {
        let events = try await kit.districtEvents(key: "2017fim")
        XCTAssertGreaterThan(events.count, 0)
    }

    func testDistrictRankings() async throws {
        let rankings = try await kit.districtRankings(key: "2017fim")
        XCTAssertGreaterThan(rankings.count, 0)

        let ranking = try XCTUnwrap(rankings.first)
        XCTAssertNotNil(ranking.teamKey)
        XCTAssertNotNil(ranking.rank)
        XCTAssertNotNil(ranking.pointTotal)

        XCTAssertNotNil(ranking.eventPoints)
        XCTAssertGreaterThan(ranking.eventPoints.count, 0)

        let eventPoints = try XCTUnwrap(ranking.eventPoints.first)
        XCTAssertNotNil(eventPoints.eventKey)
        XCTAssertNotNil(eventPoints.districtCMP)
        XCTAssertNotNil(eventPoints.alliancePoints)
        XCTAssertNotNil(eventPoints.awardPoints)
        XCTAssertNotNil(eventPoints.elimPoints)
        XCTAssertNotNil(eventPoints.qualPoints)
        XCTAssertNotNil(eventPoints.total)
    }

    func test_districTeams() async throws {
        let teams = try await kit.districtTeams(key: "2017fim")
        XCTAssertGreaterThan(teams.count, 0)
    }

}
