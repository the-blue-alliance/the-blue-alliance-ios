import Foundation
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct TeamsListViewControllerTests {

    private static func team(_ number: Int, _ nickname: String) -> TeamSimple {
        TeamSimple(key: "frc\(number)", teamNumber: number, nickname: nickname, name: nickname)
    }

    private static func makeController() -> TeamsViewController {
        let api = MockTBAAPI()
        api.teams = [team(254, "The Cheesy Poofs"), team(2590, "Nemesis"), team(1114, "Simbotics")]
        let controller = TeamsViewController(dependencies: .mock(api: api))
        controller.loadViewIfNeeded()
        return controller
    }

    /// The search filter runs off the main actor, so results land a tick later.
    private static func waitForTeams(
        _ controller: TeamsViewController,
        count: Int
    ) async -> [Int] {
        for _ in 0..<200 where controller.teams.count != count {
            try? await Task.sleep(for: .milliseconds(10))
        }
        return controller.teams.map(\.teamNumber)
    }

    @Test func narrowingThenWideningTheQueryRestoresResults() async {
        let controller = Self.makeController()
        controller.refresh()
        #expect(await Self.waitForTeams(controller, count: 3) == [254, 1114, 2590])

        controller.searchController.searchBar.text = "254"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 1) == [254])

        controller.searchController.searchBar.text = "25"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 2) == [254, 2590])

        controller.searchController.searchBar.text = ""
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 3) == [254, 1114, 2590])
    }

    @Test func matchesNumberNicknameAndName() async {
        let controller = Self.makeController()
        controller.refresh()
        _ = await Self.waitForTeams(controller, count: 3)

        controller.searchController.searchBar.text = "nemesis"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 1) == [2590])
    }

}
