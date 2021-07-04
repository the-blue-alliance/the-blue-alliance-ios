import XCTest
import TBAKit

final class TBAKitMatchTests: TBAKitTestCase {

    func test_match() async throws {
        let match = try await kit.match(key: "2017mike2_qm1")

        XCTAssertNotNil(match.compLevel)
        XCTAssertNotNil(match.eventKey)
        XCTAssertNotNil(match.key)
        XCTAssertNotNil(match.matchNumber)
        XCTAssertNotNil(match.setNumber)

        let alliances = try XCTUnwrap(match.alliances)
        XCTAssertEqual(alliances.count, 2)

        // Red alliance
        let redAlliance = try XCTUnwrap(alliances["red"])
        XCTAssertNotNil(redAlliance.score)
        XCTAssertEqual(redAlliance.teamKeys, ["frc5046", "frc6071", "frc494"])

        // Blue alliance
        let blueAlliance = try XCTUnwrap(alliances["blue"])
        XCTAssertNotNil(blueAlliance.score)
        XCTAssertEqual(blueAlliance.teamKeys, ["frc5612", "frc3534", "frc5661"])

        let breakdown = try XCTUnwrap(match.breakdown)
        XCTAssertEqual(breakdown.count, 2)

        // Breakdowns
        XCTAssertNotNil(breakdown["red"])
        XCTAssertNotNil(breakdown["blue"])

        // Videos
        let videos = try XCTUnwrap(match.videos)
        XCTAssertNotNil(match.videos)

        let video = try XCTUnwrap(videos.first)
        XCTAssertNotNil(video.type)
        XCTAssertNotNil(video.key)

    }

    func test_match_noBreakdown() async throws {
        let match = try await kit.match(key: "2014miket_qm1")

        let alliances = try XCTUnwrap(match.alliances)
        XCTAssertEqual(alliances.count, 2)
        XCTAssertNil(match.breakdown)
    }

    func test_matchZebra() async throws {
        let zebra = try await kit.matchZebra(key: "2019cc_qm1")
        XCTAssertEqual(zebra.key, "2019cc_qm1")

        XCTAssertEqual(zebra.times.count, 1521)

        XCTAssertEqual(zebra.alliances.keys.count, 2)
        XCTAssert(zebra.alliances.keys.contains("red"))
        XCTAssert(zebra.alliances.keys.contains("blue"))

        let redAlliance = try XCTUnwrap(zebra.alliances["red"])
        XCTAssertEqual(redAlliance.count, 3)
        XCTAssert(redAlliance.map({ $0.teamKey }).elementsEqual(["frc649", "frc254", "frc1983"]))
        XCTAssert(redAlliance.reduce(true, { $0 && $1.xs.count == zebra.times.count }))
        XCTAssert(redAlliance.reduce(true, { $0 && $1.ys.count == zebra.times.count }))

        let blueAlliance = try XCTUnwrap(zebra.alliances["blue"])
        XCTAssertEqual(blueAlliance.count, 3)
        XCTAssert(blueAlliance.map({ $0.teamKey }).elementsEqual(["frc5026", "frc604", "frc2930"]))
        XCTAssert(blueAlliance.reduce(true, { $0 && $1.xs.count == zebra.times.count }))
        XCTAssert(blueAlliance.reduce(true, { $0 && $1.ys.count == zebra.times.count }))
    }

    func test_matchZebra_null() async throws {
        do {
            _ = try await kit.matchZebra(key: "2015miket_qm1")
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
    }

}
