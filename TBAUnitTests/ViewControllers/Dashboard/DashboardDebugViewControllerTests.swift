import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct DashboardDebugViewControllerTests {

    @Test func loadsTheFeedAndListsPhaseAndCards() async throws {
        let api = MockTBAAPI()
        let live = APIFixtures.event(key: "2026wk3", startDate: "2026-03-19", endDate: "2026-03-21", week: 2)
        api.eventsByYear = [2026: [live]]
        api.teamsByKey = ["frc254": APIFixtures.team(254, nickname: "The Cheesy Poofs")]
        api.teamEventsByTeam = ["frc254": [live]]
        api.teamEventStatuses = ["frc254@2026wk3": APIFixtures.status()]
        let dependencies = Dependencies.mock(api: api)

        let overrides = DashboardDebugOverrides()
        overrides.now = APIFixtures.date("2026-03-20T15:00:00Z")
        overrides.teamKeys = ["frc254"]

        var changes = 0
        let inspector = DashboardDebugViewController(
            overrides: overrides,
            onChange: { changes += 1 },
            dependencies: dependencies
        )
        let window = UIWindow.makeForTesting()
        window.rootViewController = UINavigationController(rootViewController: inspector)
        window.makeKeyAndVisible()
        inspector.loadViewIfNeeded()

        let tableView = inspector.tableView!
        let feedSection = 2
        for _ in 0..<50 where tableView.numberOfRows(inSection: feedSection) < 2 {
            try await Task.sleep(for: .milliseconds(20))
        }

        // Phase, hero, this week, season.
        #expect(tableView.numberOfRows(inSection: feedSection) == 4)
        let phaseCell = inspector.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: feedSection))
        #expect(phaseCell.detailTextLabel?.text?.hasPrefix("Week 3 of 3") == true)
        let heroCell = inspector.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: feedSection))
        #expect(heroCell.textLabel?.text == "1. Hero · 254 The Cheesy Poofs")
        #expect(changes == 0)
    }

}
