import Foundation
import Testing

@testable import TBAAPI

struct APIDateTests {

    @Test func parsesToUTCMidnight() {
        #expect(APIDate.parse("2026-03-14") == Date(timeIntervalSince1970: 1_773_446_400))
    }

    @Test func parsesEveryDayOfARecentSeason() {
        var expected = Date(timeIntervalSince1970: 1_767_225_600)  // 2026-01-01
        for _ in 0..<365 {
            let string = expected.formatted(.iso8601.year().month().day())
            #expect(APIDate.parse(string) == expected, "\(string)")
            #expect(APIDate.parse(string) == expected, "\(string) (cached)")
            expected.addTimeInterval(86400)
        }
    }

    @Test(arguments: ["", "2026", "2026-13-01", "abcd-ef-gh"])
    func rejectsInvalidStrings(_ string: String) {
        #expect(APIDate.parse(string) == nil)
        #expect(APIDate.parse(string) == nil, "a rejected string must not be cached as a hit")
    }

}
