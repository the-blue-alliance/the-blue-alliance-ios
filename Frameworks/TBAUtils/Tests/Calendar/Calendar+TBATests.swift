import TBAUtils
import Foundation
import XCTest

class CalendarTBATestCase: XCTestCase {

    func test_kickoff() {
        let calendar = Calendar.current
        // 2011 - Saturday the 8th (https://en.wikipedia.org/wiki/Logo_Motion)
        let kickoff2011Components = DateComponents(year: 2011, month: Month.January.rawValue, day: 8)
        XCTAssertEqual(calendar.date(from: kickoff2011Components)!, Calendar.current.kickoff(2011))
        // 2010 - Saturday the 9th (https://en.wikipedia.org/wiki/Breakaway_(FIRST))
        let kickoff2010Components = DateComponents(year: 2010, month: Month.January.rawValue, day: 9)
        XCTAssertEqual(calendar.date(from: kickoff2010Components)!, Calendar.current.kickoff(2010))
        // 2009 - Saturday the 3rd (https://en.wikipedia.org/wiki/Lunacy_(FIRST)
        let kickoff2009Components = DateComponents(year: 2009, month: Month.January.rawValue, day: 3)
        XCTAssertEqual(calendar.date(from: kickoff2009Components)!, Calendar.current.kickoff(2009))
    }

    func test_stopBuildDay() {
        let calendar = Calendar.current
        // 2019 - Feb 19th, 2019
        let stopBuild2019Components = DateComponents(year: 2019, month: Month.February.rawValue, day: 19)
        XCTAssertEqual(calendar.date(from: stopBuild2019Components)!, Calendar.current.stopBuildDay(2019))
        // 2018 - Feb 20th, 2018
        let stopBuild2018Components = DateComponents(year: 2018, month: Month.February.rawValue, day: 20)
        XCTAssertEqual(calendar.date(from: stopBuild2018Components)!, Calendar.current.stopBuildDay(2018))
        // 2017 - Feb 21th, 2017
        let stopBuild2017Components = DateComponents(year: 2017, month: Month.February.rawValue, day: 21)
        XCTAssertEqual(calendar.date(from: stopBuild2017Components)!, Calendar.current.stopBuildDay(2017))
        // 2016 - Feb 23th, 2016
        let stopBuild2016Components = DateComponents(year: 2016, month: Month.February.rawValue, day: 23)
        XCTAssertEqual(calendar.date(from: stopBuild2016Components)!, Calendar.current.stopBuildDay(2016))
    }

}
