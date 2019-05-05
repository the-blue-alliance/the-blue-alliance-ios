import TBAKit
import TBAKitTesting
import XCTest

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

    func test_match_alliance_partial() {
        let alliance = TBAMatchAlliance(score: 2, teams: ["frc7332"])
        XCTAssertEqual(alliance.score, 2)
        XCTAssertEqual(alliance.teams, ["frc7332"])
        XCTAssertNil(alliance.surrogateTeams)
        XCTAssertNil(alliance.dqTeams)
    }

    func test_match_alliance_full() {
        let alliance = TBAMatchAlliance(score: 2, teams: ["frc7332"], surrogateTeams: ["frc1"], dqTeams: ["frc2"])
        XCTAssertEqual(alliance.score, 2)
        XCTAssertEqual(alliance.teams, ["frc7332"])
        XCTAssertEqual(alliance.surrogateTeams, ["frc1"])
        XCTAssertEqual(alliance.dqTeams, ["frc2"])
    }

    func testMatch() {
        let ex = expectation(description: "match")

        let task = kit.fetchMatch(key: "2017mike2_qm1") { (result) in
            let match = try! result.get()!
            XCTAssertNotNil(match.compLevel)
            XCTAssertNotNil(match.eventKey)
            XCTAssertNotNil(match.key)
            XCTAssertNotNil(match.matchNumber)
            XCTAssertNotNil(match.setNumber)

            let alliances = match.alliances!
            XCTAssertEqual(alliances.count, 2)

            // Red alliance
            let redAlliance = alliances["red"]!
            XCTAssertNotNil(redAlliance.score)
            XCTAssertEqual(redAlliance.teams, ["frc5046", "frc6071", "frc494"])

            // Blue alliance
            let blueAlliance = alliances["blue"]!
            XCTAssertNotNil(blueAlliance.score)
            XCTAssertEqual(blueAlliance.teams, ["frc5612", "frc3534", "frc5661"])

            XCTAssertEqual(match.breakdown?.count, 2)

            // Breakdowns
            XCTAssertNotNil(match.breakdown?["red"])
            XCTAssertNotNil(match.breakdown?["blue"])

            // Videos
            XCTAssertNotNil(match.videos)
            let video = match.videos!.first!
            XCTAssertNotNil(video.type)
            XCTAssertNotNil(video.key)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

    func testMatchNoBreakdown() {
        let ex = expectation(description: "match_no_breakdown")

        let task = kit.fetchMatch(key: "2014miket_qm1") { (result) in
            let match = try! result.get()!
            XCTAssertEqual(match.alliances!.count, 2)
            XCTAssertNil(match.breakdown)

            ex.fulfill()
        }
        kit.sendSuccessStub(for: task)

        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
        }
    }

}
