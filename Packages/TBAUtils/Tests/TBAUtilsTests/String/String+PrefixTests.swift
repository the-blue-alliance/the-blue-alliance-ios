import Foundation
import Testing

@testable import TBAUtils

struct StringPrefixTests {

    @Test func trimPrefix() {
        #expect("frc7332".trimPrefix("frc") == "7332")
    }

    @Test func trimPrefix_onlyLeading() {
        #expect("7332frc".trimPrefix("frc") == "7332frc")
    }

    @Test func trimPrefix_nonexistent() {
        #expect("frc7332".trimPrefix("ftc") == "frc7332")
    }
}
