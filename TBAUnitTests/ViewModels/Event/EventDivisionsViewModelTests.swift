import Foundation
import TBAAPI
import Testing

@testable import The_Blue_Alliance

@MainActor
struct EventDivisionsViewModelTests {

    private static let championshipKey = "2026cmptx"
    private static let divisionKeys = ["2026arc", "2026cur", "2026joh"]

    private static func makeAPI() -> MockTBAAPI {
        let api = MockTBAAPI()
        api.eventsByKey[championshipKey] = event(
            key: championshipKey,
            name: "Einstein Field",
            shortName: "Einstein",
            divisionKeys: divisionKeys
        )
        for key in divisionKeys {
            api.eventsByKey[key] = event(
                key: key,
                name: "\(key.dropFirst(4).capitalized) Division",
                shortName: String(key.dropFirst(4)).capitalized,
                parentEventKey: championshipKey
            )
        }
        return api
    }

    @Test func championshipListsItsOwnDivisions() async {
        let api = Self.makeAPI()
        let viewModel = await EventDivisionsViewModel.load(
            for: api.eventsByKey[Self.championshipKey]!,
            api: api
        )
        #expect(viewModel.others.map(\.key) == Self.divisionKeys)
        #expect(viewModel.parent == nil)
        #expect(viewModel.menuTitle == "Event Divisions")
    }

    @Test func divisionListsItsSiblingsAndItsParent() async {
        let api = Self.makeAPI()
        let viewModel = await EventDivisionsViewModel.load(
            for: api.eventsByKey["2026arc"]!,
            api: api
        )
        // Siblings come from the parent, and the division itself is excluded.
        #expect(viewModel.others.map(\.key) == ["2026cur", "2026joh"])
        #expect(viewModel.parent?.key == Self.championshipKey)
        #expect(viewModel.menuTitle == "Other Divisions")
    }

    @Test func menuUsesShortNamesAndTheRowUsesFullNames() async {
        let api = Self.makeAPI()
        let viewModel = await EventDivisionsViewModel.load(
            for: api.eventsByKey["2026arc"]!,
            api: api
        )
        #expect(viewModel.others.map(\.shortName) == ["Cur", "Joh"])
        #expect(viewModel.parent?.name == "Einstein Field")
    }

    @Test func eventWithNeitherDivisionsNorParentHasNothingToShow() async {
        let api = MockTBAAPI()
        let regional = Self.event(key: "2026caclv", name: "CA District Central Valley Event")
        let viewModel = await EventDivisionsViewModel.load(for: regional, api: api)
        #expect(viewModel.isEmpty)
        #expect(viewModel.menuTitle == nil)
    }

    @Test func aDivisionThatFailsToLoadIsSkippedRatherThanFailingTheRest() async {
        let api = Self.makeAPI()
        api.eventsByKey["2026cur"] = nil
        let viewModel = await EventDivisionsViewModel.load(
            for: api.eventsByKey[Self.championshipKey]!,
            api: api
        )
        #expect(viewModel.others.map(\.key) == ["2026arc", "2026joh"])
    }

    @Test func aDivisionWhoseParentFailsToLoadShowsNothing() async {
        let api = Self.makeAPI()
        let division = api.eventsByKey["2026arc"]!
        api.eventsByKey[Self.championshipKey] = nil
        let viewModel = await EventDivisionsViewModel.load(for: division, api: api)
        #expect(viewModel.isEmpty)
        #expect(viewModel.menuTitle == nil)
    }

    // MARK: - Test helpers

    private static func event(
        key: String,
        name: String,
        shortName: String? = nil,
        divisionKeys: [String] = [],
        parentEventKey: String? = nil
    ) -> Event {
        Event(
            key: key,
            name: name,
            eventCode: String(key.dropFirst(4)),
            eventType: ._0,
            startDate: "2026-04-29",
            endDate: "2026-05-02",
            year: 2026,
            shortName: shortName,
            eventTypeString: "",
            week: nil,
            webcasts: [],
            divisionKeys: divisionKeys,
            parentEventKey: parentEventKey
        )
    }

}
