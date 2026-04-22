import Testing

@testable import TBAAPI

struct APIEventHelpersTests {

    // MARK: - friendlyNameWithYear

    @Test func friendlyNameWithYear_noShortName_usesName() {
        let event = makeEvent(
            key: "2019miket",
            year: 2019,
            name: "FIM District Kettering University Event #1"
        )
        #expect(event.friendlyNameWithYear == "2019 FIM District Kettering University Event #1")
    }

    // TBA returns `short_name: ""` (not null) for many offseasons — e.g. 2024mmr.
    // Regression test: these should fall back to `name`, not produce "2024  Offseason".
    @Test func friendlyNameWithYear_emptyShortName_usesName() {
        let event = makeEvent(
            key: "2024mmr",
            year: 2024,
            name: "Minne Mini",
            shortName: "",
            eventTypeString: "Offseason"
        )
        #expect(event.friendlyNameWithYear == "2024 Minne Mini")
    }

    @Test func friendlyNameWithYear_withShortName_noEventType_usesEventFallback() {
        let event = makeEvent(
            key: "2019miket",
            year: 2019,
            name: "FIM District Kettering University Event #1",
            shortName: "Kettering University #1"
        )
        #expect(event.friendlyNameWithYear == "2019 Kettering University #1 Event")
    }

    @Test func friendlyNameWithYear_withShortName_andEventType_combines() {
        let event = makeEvent(
            key: "2019miket",
            year: 2019,
            name: "FIM District Kettering University Event #1",
            shortName: "Kettering University #1",
            eventTypeString: "District"
        )
        #expect(event.friendlyNameWithYear == "2019 Kettering University #1 District")
    }

    // MARK: - safeShortName / safeNameYear

    @Test func safeShortName_fallbacks() {
        // No name — falls back to key via `name` which is "" here.
        let empty = makeEvent(key: "2019miket", year: 2019, name: "")
        #expect(empty.safeShortName == "")

        // Name set, no short_name — uses name.
        let named = makeEvent(
            key: "2019miket",
            year: 2019,
            name: "FIM District Kettering University Event #1"
        )
        #expect(named.safeShortName == "FIM District Kettering University Event #1")

        // Empty short_name falls back to name.
        let emptyShort = makeEvent(
            key: "2019miket",
            year: 2019,
            name: "FIM District Kettering University Event #1",
            shortName: ""
        )
        #expect(emptyShort.safeShortName == "FIM District Kettering University Event #1")

        // Populated short_name wins.
        let short = makeEvent(
            key: "2019miket",
            year: 2019,
            name: "FIM District Kettering University Event #1",
            shortName: "Kettering University #1"
        )
        #expect(short.safeShortName == "Kettering University #1")
    }

    @Test func safeNameYear_emptyName_usesKey() {
        let empty = makeEvent(key: "2019miket", year: 2019, name: "")
        #expect(empty.safeNameYear == "2019miket")
    }

    @Test func safeNameYear_withName_prependsYear() {
        let event = makeEvent(
            key: "2019miket",
            year: 2019,
            name: "FIM District Kettering University Event #1"
        )
        #expect(event.safeNameYear == "2019 FIM District Kettering University Event #1")
    }

    // MARK: - weekString

    @Test func weekString_unknownEventType() {
        let event = makeEvent(key: "x", year: 2020, eventType: -99)
        #expect(event.weekString == "Unknown")
    }

    @Test func weekString_championship_pre2017_noCity() {
        let cmpDiv = makeEvent(key: "x", year: 2016, eventType: .championshipDivision)
        #expect(cmpDiv.weekString == "Championship")
        let cmpFinals = makeEvent(key: "x", year: 2016, eventType: .championshipFinals)
        #expect(cmpFinals.weekString == "Championship")
    }

    @Test func weekString_championship_post2017_noCity() {
        let cmpDiv = makeEvent(key: "x", year: 2017, eventType: .championshipDivision)
        #expect(cmpDiv.weekString == "Championship")
    }

    @Test func weekString_championship_post2017_withCity() {
        let cmpDiv = makeEvent(
            key: "x",
            year: 2017,
            eventType: .championshipDivision,
            city: "Detroit"
        )
        #expect(cmpDiv.weekString == "Championship - Detroit")
        let cmpFinals = makeEvent(
            key: "x",
            year: 2017,
            eventType: .championshipFinals,
            city: "Detroit"
        )
        #expect(cmpFinals.weekString == "Championship - Detroit")
    }

    @Test func weekString_unlabeled() {
        let event = makeEvent(key: "x", year: 2020, eventType: .unlabeled)
        #expect(event.weekString == "Other")
    }

    @Test func weekString_preseason() {
        let event = makeEvent(key: "x", year: 2020, eventType: .preseason)
        #expect(event.weekString == "Preseason")
    }

    @Test func weekString_offseason_noDate() {
        // Unparseable date → `month` is nil → "Offseason" (no month prefix).
        let event = makeEvent(
            key: "x",
            year: 2020,
            eventType: .offseason,
            startDate: "",
            endDate: ""
        )
        #expect(event.weekString == "Offseason")
    }

    @Test func weekString_offseason_withDate() {
        let event = makeEvent(
            key: "x",
            year: 2020,
            eventType: .offseason,
            startDate: "2020-03-01",
            endDate: "2020-03-01"
        )
        #expect(event.weekString == "March Offseason")
    }

    @Test func weekString_festivalOfChampions() {
        let event = makeEvent(key: "x", year: 2020, eventType: .festivalOfChampions)
        #expect(event.weekString == "Festival of Champions")
    }

    @Test func weekString_week_noWeek() {
        let event = makeEvent(key: "x", year: 2020, eventType: .district)
        #expect(event.weekString == "Other")
    }

    @Test func weekString_week_2016_weekZero_is05() {
        let event = makeEvent(key: "x", year: 2016, eventType: .district, week: 0)
        #expect(event.weekString == "Week 0.5")
    }

    @Test func weekString_week_2016_weekOne() {
        let event = makeEvent(key: "x", year: 2016, eventType: .district, week: 1)
        #expect(event.weekString == "Week 1")
    }

    @Test func weekString_week_2017_weekZero_is1() {
        let event = makeEvent(key: "x", year: 2017, eventType: .district, week: 0)
        #expect(event.weekString == "Week 1")
    }

    @Test func weekString_week_2017_weekOne_is2() {
        let event = makeEvent(key: "x", year: 2017, eventType: .district, week: 1)
        #expect(event.weekString == "Week 2")
    }

    // MARK: - is* type helpers

    @Test func isChampionshipEvent_falseByDefault() {
        #expect(!makeEvent(key: "x", year: 2020).isChampionshipEvent)
    }

    @Test func isChampionshipEvent_trueForDivision() {
        #expect(
            makeEvent(key: "x", year: 2020, eventType: .championshipDivision).isChampionshipEvent
        )
    }

    @Test func isChampionshipEvent_trueForFinals() {
        #expect(makeEvent(key: "x", year: 2020, eventType: .championshipFinals).isChampionshipEvent)
    }

    @Test func isChampionshipDivision() {
        #expect(
            makeEvent(key: "x", year: 2020, eventType: .championshipDivision).isChampionshipDivision
        )
        #expect(
            !makeEvent(key: "x", year: 2020, eventType: .championshipFinals).isChampionshipDivision
        )
    }

    @Test func isChampionshipFinals() {
        #expect(
            makeEvent(key: "x", year: 2020, eventType: .championshipFinals).isChampionshipFinals
        )
        #expect(
            !makeEvent(key: "x", year: 2020, eventType: .championshipDivision).isChampionshipFinals
        )
    }

    @Test func isDistrictChampionshipEvent() {
        #expect(
            makeEvent(key: "x", year: 2020, eventType: .districtChampionship)
                .isDistrictChampionshipEvent
        )
        #expect(
            makeEvent(key: "x", year: 2020, eventType: .districtChampionshipDivision)
                .isDistrictChampionshipEvent
        )
        #expect(!makeEvent(key: "x", year: 2020, eventType: .district).isDistrictChampionshipEvent)
    }

    @Test func isDistrictChampionship() {
        #expect(
            makeEvent(key: "x", year: 2020, eventType: .districtChampionship).isDistrictChampionship
        )
        #expect(
            !makeEvent(key: "x", year: 2020, eventType: .districtChampionshipDivision)
                .isDistrictChampionship
        )
    }

    @Test func isDistrictChampionshipDivision() {
        #expect(
            makeEvent(key: "x", year: 2020, eventType: .districtChampionshipDivision)
                .isDistrictChampionshipDivision
        )
        #expect(
            !makeEvent(key: "x", year: 2020, eventType: .districtChampionship)
                .isDistrictChampionshipDivision
        )
    }

    @Test func isFoC() {
        #expect(makeEvent(key: "x", year: 2020, eventType: .festivalOfChampions).isFoC)
        #expect(!makeEvent(key: "x", year: 2020).isFoC)
    }

    @Test func isPreseason() {
        #expect(makeEvent(key: "x", year: 2020, eventType: .preseason).isPreseason)
        #expect(!makeEvent(key: "x", year: 2020).isPreseason)
    }

    @Test func isOffseason() {
        #expect(makeEvent(key: "x", year: 2020, eventType: .offseason).isOffseason)
        #expect(!makeEvent(key: "x", year: 2020).isOffseason)
    }

    @Test func isRegional() {
        #expect(makeEvent(key: "x", year: 2020, eventType: .regional).isRegional)
        #expect(!makeEvent(key: "x", year: 2020, eventType: .district).isRegional)
    }

    @Test func isUnlabeled() {
        #expect(makeEvent(key: "x", year: 2020, eventType: .unlabeled).isUnlabeled)
        #expect(!makeEvent(key: "x", year: 2020).isUnlabeled)
    }

    // MARK: - hasWebsite

    @Test func hasWebsite_nilIsFalse() {
        #expect(!makeEvent(key: "x", year: 2020).hasWebsite)
    }

    @Test func hasWebsite_emptyIsFalse() {
        #expect(!makeEvent(key: "x", year: 2020, website: "").hasWebsite)
    }

    @Test func hasWebsite_populatedIsTrue() {
        #expect(makeEvent(key: "x", year: 2020, website: "https://example.com").hasWebsite)
    }

    // MARK: - isHappeningNow

    @Test func isHappeningNow_falseWhenNoDates() {
        // Can't actually build an Event without dates (init requires them), so use a
        // plainly past event.
        let event = makeEvent(
            key: "x",
            year: 2000,
            startDate: "2000-01-01",
            endDate: "2000-01-03"
        )
        #expect(!event.isHappeningNow)
    }

    @Test func isHappeningNow_futureEventIsFalse() {
        let event = makeEvent(
            key: "x",
            year: 3000,
            startDate: "3000-01-01",
            endDate: "3000-01-03"
        )
        #expect(!event.isHappeningNow)
    }

    // MARK: - dateString

    @Test func dateString_sameDay() {
        let event = makeEvent(key: "x", year: 2018, startDate: "2018-03-05", endDate: "2018-03-05")
        #expect(event.dateString == "Mar 05")
    }

    @Test func dateString_sameYear() {
        let event = makeEvent(key: "x", year: 2018, startDate: "2018-03-01", endDate: "2018-03-03")
        #expect(event.dateString == "Mar 01 to Mar 03")
    }

    @Test func dateString_differentYear() {
        let event = makeEvent(key: "x", year: 2018, startDate: "2018-12-31", endDate: "2019-01-01")
        #expect(event.dateString == "Dec 31 to Jan 01, 2019")
    }

    // MARK: - locationString

    @Test func locationString_nilWhenAllEmpty() {
        let event = makeEvent(key: "x", year: 2020)
        #expect(event.locationString == nil)
    }

    @Test func locationString_joinsPartsWithComma() {
        let event = makeEvent(
            key: "x",
            year: 2020,
            city: "Detroit",
            stateProv: "MI",
            country: "USA"
        )
        #expect(event.locationString == "Detroit, MI, USA")
    }

    @Test func locationString_fallsBackToLocationName() {
        let event = makeEvent(key: "x", year: 2020, locationName: "Cobo Center")
        #expect(event.locationString == "Cobo Center")
    }

    // MARK: - Test helpers

    private func makeEvent(
        key: String,
        year: Int,
        name: String = "",
        shortName: String? = nil,
        eventType: Int = 0,
        eventTypeString: String = "",
        week: Int? = nil,
        startDate: String = "2020-01-01",
        endDate: String = "2020-01-01",
        city: String? = nil,
        stateProv: String? = nil,
        country: String? = nil,
        locationName: String? = nil,
        website: String? = nil
    ) -> Event {
        Event(
            key: key,
            name: name,
            eventCode: key.replacingOccurrences(of: "\(year)", with: ""),
            eventType: eventType,
            city: city,
            stateProv: stateProv,
            country: country,
            startDate: startDate,
            endDate: endDate,
            year: year,
            shortName: shortName,
            eventTypeString: eventTypeString,
            week: week,
            locationName: locationName,
            website: website,
            webcasts: [],
            divisionKeys: []
        )
    }

    private func makeEvent(
        key: String,
        year: Int,
        name: String = "",
        shortName: String? = nil,
        eventType: APIEventType,
        eventTypeString: String = "",
        week: Int? = nil,
        startDate: String = "2020-01-01",
        endDate: String = "2020-01-01",
        city: String? = nil,
        stateProv: String? = nil,
        country: String? = nil,
        locationName: String? = nil,
        website: String? = nil
    ) -> Event {
        makeEvent(
            key: key,
            year: year,
            name: name,
            shortName: shortName,
            eventType: eventType.rawValue,
            eventTypeString: eventTypeString,
            week: week,
            startDate: startDate,
            endDate: endDate,
            city: city,
            stateProv: stateProv,
            country: country,
            locationName: locationName,
            website: website
        )
    }
}
