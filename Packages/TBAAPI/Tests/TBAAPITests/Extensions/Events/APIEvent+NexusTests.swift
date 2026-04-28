import Testing

@testable import TBAAPI

struct APIEventNexusTests {

    @Test func usesFirstEventCode() {
        let event = makeEvent(key: "2024casf", year: 2024, firstEventCode: "casf")
        #expect(
            event.nexusTeamPitMapURL(teamNumber: 254)?.absoluteString
                == "https://frc.nexus/en/event/2024casf/team/254/map"
        )
    }

    // 2023 had FRC-API codes that diverged from TBA event_short — eg. 2023new (TBA)
    // ↔ 2023nyny (FRC). Without first_event_code, the Nexus URL was wrong.
    @Test func usesFirstEventCode_whenDifferentFromTbaEventCode() {
        let event = makeEvent(key: "2023new", year: 2023, firstEventCode: "nyny")
        #expect(
            event.nexusTeamPitMapURL(teamNumber: 1)?.absoluteString
                == "https://frc.nexus/en/event/2023nyny/team/1/map"
        )
    }

    @Test func fallsBackToEventKey_whenFirstEventCodeMissing() {
        let event = makeEvent(key: "2024casf", year: 2024, firstEventCode: nil)
        #expect(
            event.nexusTeamPitMapURL(teamNumber: 254)?.absoluteString
                == "https://frc.nexus/en/event/2024casf/team/254/map"
        )
    }

    private func makeEvent(key: String, year: Int, firstEventCode: String?) -> Event {
        Event(
            key: key,
            name: "",
            eventCode: String(key.dropFirst(4)),
            eventType: ._0,
            startDate: "2020-01-01",
            endDate: "2020-01-01",
            year: year,
            eventTypeString: "",
            firstEventCode: firstEventCode,
            webcasts: [],
            divisionKeys: []
        )
    }
}
