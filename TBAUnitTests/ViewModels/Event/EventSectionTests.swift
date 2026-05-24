import Foundation
import TBAAPI
import Testing

@testable import The_Blue_Alliance

struct EventSectionTests {

    // MARK: - regional

    @Test func regional_singleSection() {
        let a = makeEvent(key: "2026micmp", year: 2026, eventType: .regional, week: 0)
        let b = makeEvent(key: "2026miket", year: 2026, eventType: .regional, week: 3)
        #expect(a.section == b.section)
        #expect(a.section.title == "Regional Events")
        #expect(a.section.sortOrder == APIEventType.regional.displayOrder)
    }

    // MARK: - district (the #1111 regression surface)

    // Default behavior: a district's events collapse into a single section
    // regardless of week. The Team tab and Year/Week tab rely on this.
    @Test func district_default_collapsesAcrossWeeks() {
        let fim = makeDistrict(abbreviation: "fim", displayName: "FIRST In Michigan")
        let weekOne = makeEvent(
            key: "2026mimtp",
            year: 2026,
            eventType: .district,
            district: fim,
            week: 0
        )
        let weekThree = makeEvent(
            key: "2026mikea",
            year: 2026,
            eventType: .district,
            district: fim,
            week: 2
        )
        #expect(weekOne.section == weekThree.section)
        #expect(weekOne.section.title == "FIRST In Michigan District Events")
    }

    // Regression test for https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/1111
    // Reproduces 2026 PCH: 5 district events spread across weeks + 1 DCMP.
    // When the District tab opts into week-splitting, each week becomes its
    // own section so the view matches the web layout.
    @Test func district_splitByWeek_2026PCH_splitsIntoSixSections() {
        let pch = makeDistrict(abbreviation: "pch", displayName: "Peachtree")
        let dalton = makeEvent(
            key: "2026gada",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 0
        )
        let gwinnett = makeEvent(
            key: "2026gagw",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 2
        )
        let columbus = makeEvent(
            key: "2026gaco",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 3
        )
        let albany = makeEvent(
            key: "2026gaal",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 4
        )
        let gainesville = makeEvent(
            key: "2026gaga",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 5
        )
        let dcmp = makeEvent(
            key: "2026gapch",
            year: 2026,
            eventType: .districtChampionship,
            district: pch,
            week: 7
        )

        let events = [dcmp, gainesville, albany, columbus, gwinnett, dalton]
        let sections = Set(events.map { $0.section(splitDistrictsByWeek: true) })
        // 5 distinct weeks of district events + 1 DCMP section.
        #expect(sections.count == 6)

        // Sections sort by week within district, then DCMP afterward.
        let sorted = sections.sorted()
        #expect(sorted.map(\.subOrder) == [0, 2, 3, 4, 5, 0])
        #expect(
            sorted.map(\.sortOrder) == [
                APIEventType.district.displayOrder,
                APIEventType.district.displayOrder,
                APIEventType.district.displayOrder,
                APIEventType.district.displayOrder,
                APIEventType.district.displayOrder,
                APIEventType.districtChampionship.displayOrder,
            ]
        )
    }

    @Test func district_sameWeek_sameDistrict_singleSection() {
        let pch = makeDistrict(abbreviation: "pch", displayName: "Peachtree")
        let a = makeEvent(
            key: "2026gada",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 2
        )
        let b = makeEvent(
            key: "2026gagw",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 2
        )
        #expect(a.section == b.section)
    }

    @Test func district_differentDistricts_distinctSections() {
        let pch = makeDistrict(abbreviation: "pch", displayName: "Peachtree")
        let fim = makeDistrict(abbreviation: "fim", displayName: "FIRST In Michigan")
        let pchEvent = makeEvent(
            key: "2026gada",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 0
        )
        let fimEvent = makeEvent(
            key: "2026miket",
            year: 2026,
            eventType: .district,
            district: fim,
            week: 0
        )
        #expect(pchEvent.section != fimEvent.section)
        #expect(pchEvent.section.title == "Peachtree District Events")
        #expect(fimEvent.section.title == "FIRST In Michigan District Events")
    }

    @Test func district_splitByWeek_nilWeek_sortsLast() {
        let pch = makeDistrict(abbreviation: "pch", displayName: "Peachtree")
        let weekOne = makeEvent(
            key: "2026gada",
            year: 2026,
            eventType: .district,
            district: pch,
            week: 0
        )
        let noWeek = makeEvent(
            key: "2026gaxx",
            year: 2026,
            eventType: .district,
            district: pch,
            week: nil
        )
        #expect(
            weekOne.section(splitDistrictsByWeek: true)
                < noWeek.section(splitDistrictsByWeek: true)
        )
    }

    @Test func district_nilDistrict_fallsBackToDistrictLabel() {
        let event = makeEvent(key: "2026xx", year: 2026, eventType: .district, week: 0)
        #expect(event.section.title == "District District Events")
    }

    @Test func district_emptyDisplayName_usesAbbreviationUppercased() {
        let mi = makeDistrict(abbreviation: "fim", displayName: "")
        let event = makeEvent(
            key: "2026miket",
            year: 2026,
            eventType: .district,
            district: mi,
            week: 0
        )
        #expect(event.section.title == "FIM District Events")
    }

    // MARK: - district championship

    @Test func districtChampionship_andDivision_shareSection() {
        let mi = makeDistrict(abbreviation: "fim", displayName: "FIRST In Michigan")
        let parent = makeEvent(
            key: "2026micmp",
            year: 2026,
            eventType: .districtChampionship,
            district: mi,
            week: 6
        )
        let division = makeEvent(
            key: "2026micmp1",
            year: 2026,
            eventType: .districtChampionshipDivision,
            district: mi,
            week: 6
        )
        #expect(parent.section == division.section)
        #expect(parent.section.title == "FIRST In Michigan District Championship")
    }

    @Test func districtChampionship_useDistrictDisplayName() {
        let pch = makeDistrict(abbreviation: "pch", displayName: "Peachtree")
        let dcmp = makeEvent(
            key: "2026gapch",
            year: 2026,
            eventType: .districtChampionship,
            district: pch,
            week: 7
        )
        #expect(dcmp.section.title == "Peachtree District Championship")
    }

    // MARK: - championship division / finals

    @Test func championshipDivision_pre2017_noCity() {
        let event = makeEvent(key: "2016arc", year: 2016, eventType: .championshipDivision)
        #expect(event.section.title == "Championship Divisions")
    }

    @Test func championshipDivision_post2017_withCity_includesCity() {
        let event = makeEvent(
            key: "2024arc",
            year: 2024,
            eventType: .championshipDivision,
            city: "Houston"
        )
        #expect(event.section.title == "Championship - Houston Divisions")
    }

    @Test func championshipFinals_post2017_withCity() {
        let event = makeEvent(
            key: "2024cmptx",
            year: 2024,
            eventType: .championshipFinals,
            city: "Houston"
        )
        #expect(event.section.title == "Championship - Houston")
    }

    // MARK: - festival of champions / preseason / unlabeled / forward-compat

    @Test func festivalOfChampions_singleSection() {
        let event = makeEvent(key: "2018foc", year: 2018, eventType: .festivalOfChampions)
        #expect(event.section.title == "Festival of Champions")
    }

    @Test func preseason_singleSection_sortsFirst() {
        let event = makeEvent(key: "2026wk0", year: 2026, eventType: .preseason)
        #expect(event.section.title == "Preseason Events")
        // Preseason has displayOrder -1 so it sorts before regional (0).
        let regional = makeEvent(key: "2026micmp", year: 2026, eventType: .regional)
        #expect(event.section < regional.section)
    }

    @Test func unlabeled_singleSection_sortsLast() {
        let event = makeEvent(key: "2026misc", year: 2026, eventType: .unlabeled)
        #expect(event.section.title == "Unknown Events")
        // Unlabeled has displayOrder Int.max so it sorts after every other type.
        let cmp = makeEvent(key: "2026cmptx", year: 2026, eventType: .championshipFinals)
        #expect(cmp.section < event.section)
    }

    @Test func unknownEventTypeRawValue_fallsBackToEventTypeString() {
        // EventType raw value outside APIEventType (e.g. REMOTE = 7) hits the
        // forward-compat fallback in EventSection.section.
        let event = makeEvent(
            key: "2026remote",
            year: 2026,
            eventType: 7,
            eventTypeString: "Remote"
        )
        #expect(event.section.title == "Remote Events")
        #expect(event.section.sortOrder == 7)
    }

    @Test func unknownEventTypeRawValue_emptyString_fallsBackToUnknown() {
        let event = makeEvent(key: "2026remote", year: 2026, eventType: 7, eventTypeString: "")
        #expect(event.section.title == "Unknown Events")
    }

    // MARK: - offseason

    @Test func offseason_groupedByMonth() {
        let march = makeEvent(
            key: "2024marchmadness",
            year: 2024,
            eventType: .offseason,
            startDate: "2024-03-15",
            endDate: "2024-03-16"
        )
        let october = makeEvent(
            key: "2024iri",
            year: 2024,
            eventType: .offseason,
            startDate: "2024-10-12",
            endDate: "2024-10-13"
        )
        #expect(march.section != october.section)
        #expect(march.section < october.section)
        #expect(march.section.title == "March Offseason Events")
        #expect(october.section.title == "October Offseason Events")
    }

    @Test func offseason_sameMonth_singleSection() {
        let a = makeEvent(
            key: "2024oct1",
            year: 2024,
            eventType: .offseason,
            startDate: "2024-10-01",
            endDate: "2024-10-02"
        )
        let b = makeEvent(
            key: "2024oct2",
            year: 2024,
            eventType: .offseason,
            startDate: "2024-10-20",
            endDate: "2024-10-21"
        )
        #expect(a.section == b.section)
    }

    // MARK: - cross-type sort order matches FRC season chronology

    @Test func sectionSortOrder_chronological() {
        let preseason = makeEvent(key: "p", year: 2026, eventType: .preseason)
        let regional = makeEvent(key: "r", year: 2026, eventType: .regional)
        let district = makeEvent(
            key: "d",
            year: 2026,
            eventType: .district,
            district: makeDistrict(abbreviation: "fim"),
            week: 0
        )
        let dcmp = makeEvent(key: "dc", year: 2026, eventType: .districtChampionship)
        let cmpDiv = makeEvent(
            key: "cd",
            year: 2026,
            eventType: .championshipDivision,
            city: "Houston"
        )
        let cmpFinals = makeEvent(
            key: "cf",
            year: 2026,
            eventType: .championshipFinals,
            city: "Houston"
        )
        let foc = makeEvent(key: "f", year: 2026, eventType: .festivalOfChampions)
        let offseason = makeEvent(
            key: "o",
            year: 2026,
            eventType: .offseason,
            startDate: "2026-09-01",
            endDate: "2026-09-02"
        )
        let unlabeled = makeEvent(key: "u", year: 2026, eventType: .unlabeled)

        let sorted = [
            offseason, cmpFinals, foc, district, regional, unlabeled, cmpDiv, dcmp, preseason,
        ].map(\.section).sorted()

        #expect(
            sorted.map(\.sortOrder) == [
                APIEventType.preseason.displayOrder,            // -1
                APIEventType.regional.displayOrder,             //  0
                APIEventType.district.displayOrder,             //  1
                APIEventType.districtChampionship.displayOrder, //  2
                APIEventType.championshipDivision.displayOrder, //  3
                APIEventType.championshipFinals.displayOrder,   //  4
                APIEventType.festivalOfChampions.displayOrder,  //  6
                APIEventType.offseason.displayOrder,            // 99
                APIEventType.unlabeled.displayOrder,            // Int.max
            ]
        )
    }

    // MARK: - Event.sectionAscending tie-breaking

    @Test func sectionAscending_differentSection_sectionWins() {
        let regional = makeEvent(
            key: "r",
            year: 2026,
            eventType: .regional,
            startDate: "2026-04-01",
            endDate: "2026-04-03"
        )
        // Later by date but earlier by section sort.
        #expect(Event.sectionAscending(regional, makeEvent(
            key: "d",
            year: 2026,
            eventType: .district,
            district: makeDistrict(abbreviation: "fim"),
            startDate: "2026-03-01",
            endDate: "2026-03-03",
            week: 0
        )))
    }

    @Test func sectionAscending_dcmp_divisionsBeforeFinals() {
        // DCMP divisions are played first, the DCMP parent / finals event
        // runs after them — sort should put divisions ahead of the parent.
        let mi = makeDistrict(abbreviation: "fim")
        let parent = makeEvent(
            key: "2026micmp",
            year: 2026,
            eventType: .districtChampionship,
            district: mi,
            week: 6
        )
        let division = makeEvent(
            key: "2026micmp1",
            year: 2026,
            eventType: .districtChampionshipDivision,
            district: mi,
            week: 6
        )
        #expect(Event.sectionAscending(division, parent))
        #expect(!Event.sectionAscending(parent, division))
    }

    @Test func sectionAscending_cmp_divisionsBeforeFinals() {
        // CMP divisions play before the finals on Einstein.
        let division = makeEvent(
            key: "2026arc",
            year: 2026,
            eventType: .championshipDivision,
            city: "Houston"
        )
        let finals = makeEvent(
            key: "2026cmptx",
            year: 2026,
            eventType: .championshipFinals,
            city: "Houston"
        )
        #expect(Event.sectionAscending(division, finals))
        #expect(!Event.sectionAscending(finals, division))
    }

    @Test func sectionAscending_sameSection_sameType_earlierDateWins() {
        let mi = makeDistrict(abbreviation: "fim")
        let earlier = makeEvent(
            key: "a",
            year: 2026,
            eventType: .district,
            district: mi,
            startDate: "2026-03-01",
            endDate: "2026-03-03",
            week: 0
        )
        let later = makeEvent(
            key: "b",
            year: 2026,
            eventType: .district,
            district: mi,
            startDate: "2026-03-08",
            endDate: "2026-03-10",
            week: 0
        )
        #expect(Event.sectionAscending(earlier, later))
    }

    @Test func sectionAscending_sameSection_sameDate_keyBreaksTie() {
        let mi = makeDistrict(abbreviation: "fim")
        let a = makeEvent(
            key: "2026miaaa",
            year: 2026,
            eventType: .district,
            district: mi,
            startDate: "2026-03-01",
            endDate: "2026-03-03",
            week: 0
        )
        let b = makeEvent(
            key: "2026mizzz",
            year: 2026,
            eventType: .district,
            district: mi,
            startDate: "2026-03-01",
            endDate: "2026-03-03",
            week: 0
        )
        #expect(Event.sectionAscending(a, b))
    }

    // MARK: - Test helpers

    private func makeEvent(
        key: String,
        year: Int,
        name: String = "",
        eventType: Int,
        eventTypeString: String = "",
        district: District? = nil,
        startDate: String = "2020-01-01",
        endDate: String = "2020-01-01",
        week: Int? = nil,
        city: String? = nil
    ) -> Event {
        Event(
            key: key,
            name: name,
            eventCode: key.replacingOccurrences(of: "\(year)", with: ""),
            eventType: Components.Schemas.EventType(rawValue: eventType) ?? ._0,
            district: district,
            city: city,
            startDate: startDate,
            endDate: endDate,
            year: year,
            eventTypeString: eventTypeString,
            week: week,
            webcasts: [],
            divisionKeys: []
        )
    }

    private func makeEvent(
        key: String,
        year: Int,
        name: String = "",
        eventType: APIEventType,
        eventTypeString: String = "",
        district: District? = nil,
        startDate: String = "2020-01-01",
        endDate: String = "2020-01-01",
        week: Int? = nil,
        city: String? = nil
    ) -> Event {
        makeEvent(
            key: key,
            year: year,
            name: name,
            eventType: eventType.rawValue,
            eventTypeString: eventTypeString,
            district: district,
            startDate: startDate,
            endDate: endDate,
            week: week,
            city: city
        )
    }

    private func makeDistrict(
        abbreviation: String,
        displayName: String = ""
    ) -> District {
        District(
            abbreviation: abbreviation,
            displayName: displayName,
            key: "2026\(abbreviation)",
            year: 2026,
            officialAdvancementCounts: .init(dcmp: 0, cmp: 0)
        )
    }
}
