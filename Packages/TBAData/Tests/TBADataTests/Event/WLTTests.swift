import TBAData
import XCTest

class WLTTests: TBADataTestCase {

    func test_init() {
        let wlt = WLT(wins: 1, losses: 2, ties: 3)
        XCTAssertEqual(wlt.wins, 1)
        XCTAssertEqual(wlt.losses, 2)
        XCTAssertEqual(wlt.ties, 3)
    }

    func test_stringValue() {
        let wlt = WLT(wins: 1, losses: 2, ties: 3)
        XCTAssertEqual(wlt.stringValue, "1-2-3")
    }

    func test_hash() {
        // This test is necessary for the diffable data source stuff
        // We need to make sure that two WLT objects with the same values
        // hash to the same value.
        let one = WLT(wins: 1, losses: 2, ties: 3)
        let two = WLT(wins: 1, losses: 2, ties: 3)
        XCTAssertEqual(one.hash, two.hash)
    }

}
