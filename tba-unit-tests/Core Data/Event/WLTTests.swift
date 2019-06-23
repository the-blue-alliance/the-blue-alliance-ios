import XCTest
@testable import The_Blue_Alliance

class WLTTests: CoreDataTestCase {

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

}
