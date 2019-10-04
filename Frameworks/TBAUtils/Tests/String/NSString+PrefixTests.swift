import TBAUtils
import XCTest

class StringPrefixTestCase: XCTestCase {

    func test_prefix() {
        let str = "frc7332"
        XCTAssertEqual(str.trimPrefix("frc"), "7332")
    }

    func test_prefix_end() {
        let str = "7332frc"
        XCTAssertEqual(str.trimPrefix("frc"), "7332frc")
    }

    func test_prefix_nonexistent() {
        let str = "frc7332"
        XCTAssertEqual(str.trimPrefix("ftc"), "frc7332")
    }

}
