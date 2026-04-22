import Foundation
import Testing

@testable import TBAUtils

struct CalendarTBATests {

    @Test func kickoff() {
        let calendar = Calendar.current
        // 2011 - Saturday the 8th (https://en.wikipedia.org/wiki/Logo_Motion)
        let kickoff2011 = calendar.date(
            from: DateComponents(year: 2011, month: Month.January.rawValue, day: 8)
        )!
        #expect(calendar.kickoff(2011) == kickoff2011)
        // 2010 - Saturday the 9th (https://en.wikipedia.org/wiki/Breakaway_(FIRST))
        let kickoff2010 = calendar.date(
            from: DateComponents(year: 2010, month: Month.January.rawValue, day: 9)
        )!
        #expect(calendar.kickoff(2010) == kickoff2010)
        // 2009 - Saturday the 3rd (https://en.wikipedia.org/wiki/Lunacy_(FIRST)
        let kickoff2009 = calendar.date(
            from: DateComponents(year: 2009, month: Month.January.rawValue, day: 3)
        )!
        #expect(calendar.kickoff(2009) == kickoff2009)
    }

    @Test func stopBuildDay() {
        let calendar = Calendar.current
        // 2019 - Feb 19th, 2019
        let stopBuild2019 = calendar.date(
            from: DateComponents(year: 2019, month: Month.February.rawValue, day: 19)
        )!
        #expect(calendar.stopBuildDay(2019) == stopBuild2019)
        // 2018 - Feb 20th, 2018
        let stopBuild2018 = calendar.date(
            from: DateComponents(year: 2018, month: Month.February.rawValue, day: 20)
        )!
        #expect(calendar.stopBuildDay(2018) == stopBuild2018)
        // 2017 - Feb 21th, 2017
        let stopBuild2017 = calendar.date(
            from: DateComponents(year: 2017, month: Month.February.rawValue, day: 21)
        )!
        #expect(calendar.stopBuildDay(2017) == stopBuild2017)
        // 2016 - Feb 23rd, 2016
        let stopBuild2016 = calendar.date(
            from: DateComponents(year: 2016, month: Month.February.rawValue, day: 23)
        )!
        #expect(calendar.stopBuildDay(2016) == stopBuild2016)
    }
}
