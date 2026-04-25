import Testing

@testable import TBAAPI

struct EventKeyHelpersTests {

    // MARK: - EventKey.year

    @Test func year_parsesYearPrefix() {
        #expect(("2024nyro" as EventKey).year == 2024)
    }

    @Test func year_nilForMalformedKey() {
        #expect(("abcd" as EventKey).year == nil)
        #expect(("" as EventKey).year == nil)
    }

    // MARK: - EventKey.eventCode

    @Test func eventCode_dropsYearPrefix() {
        #expect(("2024nyro" as EventKey).eventCode == "nyro")
    }

    @Test func eventCode_handlesEmptyAfterYear() {
        #expect(("2024" as EventKey).eventCode == "")
    }
}
