import XCTest
@testable import TBA

class TBAMatchTests: TBAKitTestCase {

    func test_match_init() {
        let match = TBAMatch(key: "2018miket_qm1", compLevel: "qm", setNumber: 1, matchNumber: 1, eventKey: "2018miket")
        XCTAssertEqual(match.key, "2018miket_qm1")
        XCTAssertEqual(match.compLevel, "qm")
        XCTAssertEqual(match.setNumber, 1)
        XCTAssertEqual(match.matchNumber, 1)
        XCTAssertEqual(match.eventKey, "2018miket")
    }

    func test_match_video() {
        let video = TBAMatchVideo(key: "key", type: "type")
        XCTAssertEqual(video.key, "key")
        XCTAssertEqual(video.type, "type")
    }

    func teset_something() {
        let alliance = TBAMatchAlliance(score: 2, teams: ["frc7332"])
        XCTAssertEqual(alliance.score, 2)
        XCTAssertEqual(alliance.teams, ["frc7332"])
    }

    func testMatch() {
        let ex = expectation(description: "match")
        
        let task = kit.fetchMatch(key: "2017mike2_qm1") { (match, error) in
            XCTAssertNotNil(match)
            XCTAssertNotNil(match?.compLevel)
            XCTAssertNotNil(match?.eventKey)
            XCTAssertNotNil(match?.key)
            XCTAssertNotNil(match?.matchNumber)
            XCTAssertNotNil(match?.setNumber)

            XCTAssertEqual(match?.alliances?.count, 2)

            // Red alliance
            let redAlliance = match?.alliances?["red"]
            XCTAssertNotNil(redAlliance)
            XCTAssertNotNil(redAlliance?.score)
            XCTAssertEqual(redAlliance?.teams, ["frc5046", "frc6071", "frc494"])
            
            // Blue alliance
            let blueAlliance = match?.alliances?["blue"]
            XCTAssertNotNil(blueAlliance)
            XCTAssertNotNil(blueAlliance?.score)
            XCTAssertEqual(blueAlliance?.teams, ["frc5612", "frc3534", "frc5661"])

            XCTAssertEqual(match?.breakdown?.count, 2)

            // Breakdowns
            XCTAssertNotNil(match?.breakdown?["red"])
            XCTAssertNotNil(match?.breakdown?["blue"])
            
            // Videos
            XCTAssertNotNil(match?.videos)
            let video = match!.videos!.first!
            XCTAssertNotNil(video.type)
            XCTAssertNotNil(video.key)

            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testMatchNoBreakdown() {
        let ex = expectation(description: "match_no_breakdown")
        
        let task = kit.fetchMatch(key: "2014miket_qm1") { (match, error) in
            XCTAssertNotNil(match)
            XCTAssertEqual(match?.alliances?.count, 2)
            XCTAssertNil(match?.breakdown)

            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testMatchTimeseries() {
        let ex = expectation(description: "match_no_timeseries")
        
        let task = kit.fetchMatchTimeseries(key: "2018carv_qm1") { (timeseries, error) in
            XCTAssertNotNil(timeseries)
            XCTAssertGreaterThan(timeseries!.count, 0)

            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testMatchNoTimeseries() {
        let ex = expectation(description: "match_no_timeseries")

        let task = kit.fetchMatchTimeseries(key: "2018misjo_sf1m2") { (timeseries, error) in
            XCTAssertNotNil(timeseries)
            XCTAssertEqual(timeseries!.count, 0)
            
            XCTAssertNil(error)
            
            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }
}
