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

    // MARK: - Test helpers

    private func makeEvent(
        key: String,
        year: Int,
        name: String = "",
        eventType: APIEventType,
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
}
