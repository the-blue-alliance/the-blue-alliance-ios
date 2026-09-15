import Foundation
import TBAAPI
import Testing

@testable import The_Blue_Alliance

struct WeekEventsViewControllerFilterTests {

    @Test func nilWeekEvent_returnsEmpty() {
        let events = [makeEvent(key: "2026micmp", year: 2026, eventType: .regional, week: 0)]
        #expect(WeekEventsViewController.filter(events, for: nil).isEmpty)
    }

    @Test func filtersOutOtherYears() {
        let selected = makeEvent(key: "2026miket", year: 2026, eventType: .district, week: 0)
        let in2026 = makeEvent(key: "2026micmp", year: 2026, eventType: .district, week: 0)
        let in2025 = makeEvent(key: "2025micmp", year: 2025, eventType: .district, week: 0)
        let result = WeekEventsViewController.filter([in2026, in2025], for: selected)
        #expect(result.map(\.key) == ["2026micmp"])
    }

    @Test func weekEventWithWeek_filtersByWeekIndex() {
        // Selecting a Week 1 event (week=0) should return only same-year week=0 events,
        // regardless of event type — mixing regional + district + DCMP is intentional.
        let selected = makeEvent(key: "2026miket", year: 2026, eventType: .district, week: 0)
        let week0Regional = makeEvent(
            key: "2026wmar",
            year: 2026,
            eventType: .regional,
            week: 0
        )
        let week0Dcmp = makeEvent(
            key: "2026micmp",
            year: 2026,
            eventType: .districtChampionship,
            week: 0
        )
        let week2 = makeEvent(key: "2026miann", year: 2026, eventType: .district, week: 2)
        let result = WeekEventsViewController.filter(
            [week0Regional, week0Dcmp, week2],
            for: selected
        )
        #expect(Set(result.map(\.key)) == ["2026wmar", "2026micmp"])
    }

    @Test func championshipFinals_returnsFinalsAndDivisions() {
        // CMP finals events have no `week`. Filter should bundle the finals
        // with its divisions via parentEventKey.
        let finals = makeEvent(
            key: "2026cmptx",
            year: 2026,
            eventType: .championshipFinals,
            week: nil
        )
        let division1 = makeEvent(
            key: "2026arc",
            year: 2026,
            eventType: .championshipDivision,
            week: nil,
            parentEventKey: "2026cmptx"
        )
        let division2 = makeEvent(
            key: "2026cur",
            year: 2026,
            eventType: .championshipDivision,
            week: nil,
            parentEventKey: "2026cmptx"
        )
        // Different CMP year — should be excluded by same-year filter.
        let otherYearDivision = makeEvent(
            key: "2025arc",
            year: 2025,
            eventType: .championshipDivision,
            week: nil,
            parentEventKey: "2025cmptx"
        )
        // Different parent — same year but different CMP city, must not bleed in.
        let unrelatedDivision = makeEvent(
            key: "2026new",
            year: 2026,
            eventType: .championshipDivision,
            week: nil,
            parentEventKey: "2026cmpne"
        )
        // A regular district event in the same year — must not appear.
        let district = makeEvent(key: "2026miket", year: 2026, eventType: .district, week: 0)

        let result = WeekEventsViewController.filter(
            [finals, division1, division2, otherYearDivision, unrelatedDivision, district],
            for: finals
        )
        #expect(Set(result.map(\.key)) == ["2026cmptx", "2026arc", "2026cur"])
    }

    @Test func offseason_returnsSameMonthEvents() {
        let selected = makeEvent(
            key: "2024iri",
            year: 2024,
            eventType: .offseason,
            startDate: "2024-10-12",
            endDate: "2024-10-13",
            week: nil
        )
        let sameMonthA = makeEvent(
            key: "2024oct1",
            year: 2024,
            eventType: .offseason,
            startDate: "2024-10-01",
            endDate: "2024-10-02",
            week: nil
        )
        let sameMonthB = makeEvent(
            key: "2024oct2",
            year: 2024,
            eventType: .offseason,
            startDate: "2024-10-30",
            endDate: "2024-10-31",
            week: nil
        )
        let differentMonth = makeEvent(
            key: "2024nov",
            year: 2024,
            eventType: .offseason,
            startDate: "2024-11-05",
            endDate: "2024-11-06",
            week: nil
        )
        // Same month but not offseason — must be excluded.
        let sameMonthDistrict = makeEvent(
            key: "2024mioct",
            year: 2024,
            eventType: .district,
            startDate: "2024-10-15",
            endDate: "2024-10-16",
            week: nil
        )
        let result = WeekEventsViewController.filter(
            [sameMonthA, sameMonthB, differentMonth, sameMonthDistrict],
            for: selected
        )
        #expect(Set(result.map(\.key)) == ["2024oct1", "2024oct2"])
    }

    @Test func defaultBranch_preseason_filtersByEventType() {
        // Preseason events have no `week`; filter falls through to the
        // `default` branch and matches by eventTypeEnum.
        let selected = makeEvent(key: "2026wk0", year: 2026, eventType: .preseason, week: nil)
        let otherPreseason = makeEvent(
            key: "2026demo",
            year: 2026,
            eventType: .preseason,
            week: nil
        )
        let regional = makeEvent(key: "2026micmp", year: 2026, eventType: .regional, week: 0)
        let result = WeekEventsViewController.filter([otherPreseason, regional], for: selected)
        #expect(result.map(\.key) == ["2026demo"])
    }
}

struct WeekEventsGroupingTests {

    // 2026 Israel district events were delayed to weeks 17–19, after Championship.
    @Test func weeksDelayedPastChampionship_sortAfterIt() {
        let events = [
            makeEvent(
                key: "2026isde1",
                year: 2026,
                eventType: .district,
                startDate: "2026-06-28",
                endDate: "2026-06-29",
                week: 16
            ),
            makeEvent(
                key: "2026isde2",
                year: 2026,
                eventType: .district,
                startDate: "2026-06-30",
                endDate: "2026-07-01",
                week: 17
            ),
            makeEvent(
                key: "2026iscmp",
                year: 2026,
                eventType: .districtChampionship,
                startDate: "2026-07-06",
                endDate: "2026-07-08",
                week: 18
            ),
            makeEvent(
                key: "2026off",
                year: 2026,
                eventType: .offseason,
                startDate: "2026-06-20",
                endDate: "2026-06-21"
            ),
            makeEvent(
                key: "2026cmptx",
                year: 2026,
                eventType: .championshipFinals,
                city: "Houston",
                startDate: "2026-05-02",
                endDate: "2026-05-02"
            ),
            makeEvent(
                key: "2026gal",
                year: 2026,
                eventType: .championshipDivision,
                city: "Houston",
                startDate: "2026-04-29",
                endDate: "2026-05-02",
                parentEventKey: "2026cmptx"
            ),
            makeEvent(
                key: "2026utwv",
                year: 2026,
                eventType: .regional,
                startDate: "2026-04-16",
                endDate: "2026-04-18",
                week: 6
            ),
            makeEvent(
                key: "2026mimtp",
                year: 2026,
                eventType: .district,
                startDate: "2026-02-26",
                endDate: "2026-02-28",
                week: 0
            ),
            makeEvent(
                key: "2026pre",
                year: 2026,
                eventType: .preseason,
                startDate: "2026-01-10",
                endDate: "2026-01-10"
            ),
        ]
        #expect(
            WeekEventsGrouping.weekEvents(for: 2026, from: events).map(\.weekString) == [
                "Preseason",
                "Week 1",
                "Week 7",
                "Championship - Houston",
                "Week 17",
                "Week 18",
                "Week 19",
                "June Offseason",
            ]
        )
    }

    // 2017: two championships, then the Festival of Champions in late July,
    // with offseason events starting in May.
    @Test func dualChampionshipsAndFoC_inDateOrder_beforeOffseason() {
        let events = [
            makeEvent(
                key: "2017mosc",
                year: 2017,
                eventType: .offseason,
                startDate: "2017-05-12",
                endDate: "2017-05-13"
            ),
            makeEvent(
                key: "2017nhfoc",
                year: 2017,
                eventType: .festivalOfChampions,
                startDate: "2017-07-29",
                endDate: "2017-07-30"
            ),
            makeEvent(
                key: "2017cmpmo",
                year: 2017,
                eventType: .championshipFinals,
                city: "St. Louis",
                startDate: "2017-04-29",
                endDate: "2017-04-29"
            ),
            makeEvent(
                key: "2017cmptx",
                year: 2017,
                eventType: .championshipFinals,
                city: "Houston",
                startDate: "2017-04-22",
                endDate: "2017-04-22"
            ),
            makeEvent(
                key: "2017nhgrs",
                year: 2017,
                eventType: .district,
                startDate: "2017-04-06",
                endDate: "2017-04-08",
                week: 6
            ),
        ]
        #expect(
            WeekEventsGrouping.weekEvents(for: 2017, from: events).map(\.weekString) == [
                "Week 7",
                "Championship - Houston",
                "Championship - St. Louis",
                "Festival of Champions",
                "May Offseason",
            ]
        )
    }

    @Test func unlabeledEvent_sortsLast() {
        let weekOne = makeEvent(
            key: "2026ohcl",
            year: 2026,
            eventType: .regional,
            startDate: "2026-02-25",
            endDate: "2026-02-28",
            week: 0
        )
        let unlabeled = makeEvent(
            key: "2026misc",
            year: 2026,
            eventType: .unlabeled,
            startDate: "2026-03-01",
            endDate: "2026-03-01"
        )
        let offseason = makeEvent(
            key: "2026off",
            year: 2026,
            eventType: .offseason,
            startDate: "2026-09-12",
            endDate: "2026-09-13"
        )
        #expect(
            WeekEventsGrouping.weekEvents(for: 2026, from: [unlabeled, offseason, weekOne])
                .map(\.weekString) == ["Week 1", "September Offseason", "Other"]
        )
    }

    @Test func sameWeek_matchesAnyEventInTheBucket() {
        let representative = makeEvent(
            key: "2026grc",
            year: 2026,
            eventType: .offseason,
            startDate: "2026-09-11",
            endDate: "2026-09-12"
        )
        let selected = makeEvent(
            key: "2026cc",
            year: 2026,
            eventType: .offseason,
            startDate: "2026-09-18",
            endDate: "2026-09-20"
        )
        let october = makeEvent(
            key: "2026oct",
            year: 2026,
            eventType: .offseason,
            startDate: "2026-10-03",
            endDate: "2026-10-04"
        )
        let lastYear = makeEvent(
            key: "2025cc",
            year: 2025,
            eventType: .offseason,
            startDate: "2025-09-19",
            endDate: "2025-09-21"
        )
        #expect(WeekEventsGrouping.isSameWeek(representative, selected))
        #expect(!WeekEventsGrouping.isSameWeek(representative, october))
        #expect(!WeekEventsGrouping.isSameWeek(selected, lastYear))
    }
}

// MARK: - Test helpers

private func makeEvent(
    key: String,
    year: Int,
    name: String = "",
    eventType: APIEventType,
    city: String? = nil,
    startDate: String = "2026-01-01",
    endDate: String = "2026-01-01",
    week: Int? = nil,
    parentEventKey: String? = nil
) -> Event {
    Event(
        key: key,
        name: name,
        eventCode: key.replacingOccurrences(of: "\(year)", with: ""),
        eventType: Components.Schemas.EventType(rawValue: eventType.rawValue) ?? ._0,
        city: city,
        startDate: startDate,
        endDate: endDate,
        year: year,
        eventTypeString: "",
        week: week,
        webcasts: [],
        divisionKeys: [],
        parentEventKey: parentEventKey
    )
}
