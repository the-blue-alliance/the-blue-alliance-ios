import XCTest
@testable import The_Blue_Alliance

class Int16SuffixTestCase: XCTestCase {

    func test_suffix_positive() {
        test_suffix_multiple(multiplier: 1)
    }

    func test_suffix_negative() {
        test_suffix_multiple(multiplier: -1)
    }

    func test_suffix_multiple(multiplier: Int) {
        // A weird one, but technically right
        XCTAssertEqual((0 * multiplier).suffix, "th")
        // Test lastOne + a few
        XCTAssertEqual((1 * multiplier).suffix, "st")
        XCTAssertEqual((2 * multiplier).suffix, "nd")
        XCTAssertEqual((3 * multiplier).suffix, "rd")
        XCTAssertEqual((4 * multiplier).suffix, "th")
        XCTAssertEqual((5 * multiplier).suffix, "th")
        // Test lastTwo range inclusive
        XCTAssertEqual((10 * multiplier).suffix, "th")
        XCTAssertEqual((11 * multiplier).suffix, "th")
        XCTAssertEqual((12 * multiplier).suffix, "th")
        XCTAssertEqual((20 * multiplier).suffix, "th")
        XCTAssertEqual((21 * multiplier).suffix, "st")
        // Test a big number
        XCTAssertEqual((32007 * multiplier).suffix, "th")
    }

}
