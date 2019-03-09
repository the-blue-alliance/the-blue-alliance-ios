import XCTest
@testable import TBA

class TBADistrictTests: TBAKitTestCase {

    func test_district_init() {
        let district = TBADistrict(abbreviation: "fim", name: "FIRST in Michigan", key: "2018fim", year: 2018)
        XCTAssertEqual(district.abbreviation, "fim")
        XCTAssertEqual(district.name, "FIRST in Michigan")
        XCTAssertEqual(district.key, "2018fim")
        XCTAssertEqual(district.year, 2018)
    }

    func test_districtRanking_init() {
        let ranking = TBADistrictRanking(teamKey: "frc7332", rank: 1, pointTotal: 3, eventPoints: [])
        XCTAssertEqual(ranking.teamKey, "frc7332")
        XCTAssertEqual(ranking.rank, 1)
        XCTAssertEqual(ranking.pointTotal, 3)
        XCTAssertEqual(ranking.eventPoints, [])
    }

    func test_districtEventPoints_init() {
        let points = TBADistrictEventPoints(teamKey: "frc7332", eventKey: "2018miket", alliancePoints: 1, awardPoints: 2, qualPoints: 3, elimPoints: 4, total: 5)
        XCTAssertEqual(points.teamKey, "frc7332")
        XCTAssertEqual(points.eventKey, "2018miket")
        XCTAssertEqual(points.alliancePoints, 1)
        XCTAssertEqual(points.awardPoints, 2)
        XCTAssertEqual(points.qualPoints, 3)
        XCTAssertEqual(points.elimPoints, 4)
        XCTAssertEqual(points.total, 5)
    }

    func test_districtPointsTiebreaker_init() {
        let tiebreaker = TBADistrictPointsTiebreaker(teamKey: "frc7332", highestQualScores: [1, 2, 3], qualWins: 4)
        XCTAssertEqual(tiebreaker.teamKey, "frc7332")
        XCTAssertEqual(tiebreaker.highestQualScores, [1, 2, 3])
        XCTAssertEqual(tiebreaker.qualWins, 4)
    }

    func testDistrictsYear() {
        let ex = expectation(description: "districts_year")
        
        let task = kit.fetchDistricts(year: 2017) { (districts, error) in
            XCTAssertNotNil(districts)
            XCTAssertGreaterThan(districts!.count, 0)
            
            let district = districts?.first
            XCTAssertNotNil(district?.abbreviation)
            XCTAssertNotNil(district?.name)
            XCTAssertNotNil(district?.key)
            XCTAssertNotNil(district?.year)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testDistrictEvents() {
        let ex = expectation(description: "district_events")
        
        let task = kit.fetchDistrictEvents(key: "2017fim") { (events, error) in
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
    
    func testDistrictRankings() {
        let ex = expectation(description: "district_rankings")
        
        let task = kit.fetchDistrictRankings(key: "2017fim") { (rankings, error) in
            XCTAssertNotNil(rankings)
            XCTAssertGreaterThan(rankings!.count, 0)
            
            let ranking = rankings!.first!
            XCTAssertNotNil(ranking.teamKey)
            XCTAssertNotNil(ranking.rank)
            XCTAssertNotNil(ranking.pointTotal)
            
            XCTAssertNotNil(ranking.eventPoints)
            XCTAssertGreaterThan(ranking.eventPoints.count, 0)
            
            let eventPoints = ranking.eventPoints.first!
            XCTAssertNotNil(eventPoints.eventKey)
            XCTAssertNotNil(eventPoints.teamKey)
            XCTAssertNotNil(eventPoints.districtCMP)
            XCTAssertNotNil(eventPoints.alliancePoints)
            XCTAssertNotNil(eventPoints.awardPoints)
            XCTAssertNotNil(eventPoints.elimPoints)
            XCTAssertNotNil(eventPoints.qualPoints)
            XCTAssertNotNil(eventPoints.total)
            
            XCTAssertNil(error)
            
            ex.fulfill()

        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testDistricTeams() {
        let ex = expectation(description: "district_teams")
        
        let task = kit.fetchDistrictTeams(key: "2017fim") { (teams, error) in
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
    
}
