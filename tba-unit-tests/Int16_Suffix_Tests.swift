import XCTest
@testable import The_Blue_Alliance

import XCTest

class Int16_Suffix_Tests: XCTestCase {
    
    func test_suffix_positive() {
        test_suffix_multiple(multiplier: 1)
    }

    func test_suffix_negative() {
        test_suffix_multiple(multiplier: -1)
    }

    func test_suffix_multiple(multiplier: Int) {
        // A weird one, but technically right
        XCTAssertEqual(Int16(0 * multiplier).suffix(), "th")
        // Test lastOne + a few
        XCTAssertEqual(Int16(1 * multiplier).suffix(), "st")
        XCTAssertEqual(Int16(2 * multiplier).suffix(), "nd")
        XCTAssertEqual(Int16(3 * multiplier).suffix(), "rd")
        XCTAssertEqual(Int16(4 * multiplier).suffix(), "th")
        XCTAssertEqual(Int16(5 * multiplier).suffix(), "th")
        // Test lastTwo range inclusive
        XCTAssertEqual(Int16(10 * multiplier).suffix(), "th")
        XCTAssertEqual(Int16(11 * multiplier).suffix(), "th")
        XCTAssertEqual(Int16(12 * multiplier).suffix(), "th")
        XCTAssertEqual(Int16(20 * multiplier).suffix(), "th")
        XCTAssertEqual(Int16(21 * multiplier).suffix(), "st")
        // Test a big number
        XCTAssertEqual(Int16(32007 * multiplier).suffix(), "th")
    }
    
}
