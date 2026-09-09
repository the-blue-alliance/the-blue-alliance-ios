import Foundation
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct TeamEventsViewControllerTests {

    private static func event(_ key: String, year: Int) -> Event {
        Event(
            key: key,
            name: key,
            eventCode: String(key.dropFirst(4)),
            eventType: ._0,
            startDate: "\(year)-03-01",
            endDate: "\(year)-03-03",
            year: year,
            eventTypeString: "",
            week: 0,
            webcasts: [],
            divisionKeys: [],
            parentEventKey: nil
        )
    }

    private static func makeController(api: MockTBAAPI) -> TeamEventsViewController {
        api.teamEventsByYear = [
            2025: [event("2025miket", year: 2025)],
            2026: [event("2026miket", year: 2026)],
        ]
        let controller = TeamEventsViewController(
            teamKey: "frc7332",
            year: 2025,
            dependencies: .mock(api: api)
        )
        controller.loadViewIfNeeded()
        return controller
    }

    private static func waitForEvents(
        _ controller: TeamEventsViewController,
        keys: [String]
    ) async -> [String] {
        for _ in 0..<200 where controller.events.map(\.key) != keys {
            try? await Task.sleep(for: .milliseconds(10))
        }
        return controller.events.map(\.key)
    }

    @Test func changingYearClearsTheListBeforeTheNewYearLoads() async {
        let api = MockTBAAPI()
        let controller = Self.makeController(api: api)
        controller.refresh()
        #expect(await Self.waitForEvents(controller, keys: ["2025miket"]) == ["2025miket"])

        api.latency = .milliseconds(200)
        controller.year = 2026
        #expect(controller.events.isEmpty)
        #expect(controller.isRefreshing)

        #expect(await Self.waitForEvents(controller, keys: ["2026miket"]) == ["2026miket"])
        #expect(!controller.isRefreshing)
    }

    @Test func aResponseThatOutlivesItsCancelledRefreshDoesNotLand() async {
        let api = MockTBAAPI()
        let controller = Self.makeController(api: api)
        api.latency = .milliseconds(100)
        api.latencyIgnoresCancellation = true
        controller.refresh()

        // Switch years while 2025 is in flight. Cancelling can't stop its
        // response from coming back; the refresh has to drop it instead.
        try? await Task.sleep(for: .milliseconds(20))
        controller.year = 2026
        #expect(await Self.waitForEvents(controller, keys: ["2026miket"]) == ["2026miket"])
        #expect(!controller.isRefreshing)

        try? await Task.sleep(for: .milliseconds(200))
        #expect(controller.events.map(\.key) == ["2026miket"])
    }

    @Test func aCancelledRefreshLeavesTheNewerRefreshSpinning() async {
        let api = MockTBAAPI()
        let controller = Self.makeController(api: api)
        api.latency = .milliseconds(200)
        controller.refresh()

        try? await Task.sleep(for: .milliseconds(20))
        controller.year = 2026
        // The 2025 task is cancelled and unwinds here; the 2026 task is still
        // waiting on the mock's latency and must still own the refresh state.
        try? await Task.sleep(for: .milliseconds(50))
        #expect(controller.isRefreshing)
        #expect(controller.events.isEmpty)

        #expect(await Self.waitForEvents(controller, keys: ["2026miket"]) == ["2026miket"])
        #expect(!controller.isRefreshing)
    }

}
