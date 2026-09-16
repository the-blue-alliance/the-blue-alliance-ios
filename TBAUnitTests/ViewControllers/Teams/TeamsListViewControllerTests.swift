import Foundation
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct TeamsListViewControllerTests {

    private static func team(
        _ number: Int,
        _ nickname: String,
        name: String? = nil,
        city: String? = nil
    ) -> TeamSimple {
        TeamSimple(
            key: "frc\(number)",
            teamNumber: number,
            nickname: nickname,
            name: name ?? nickname,
            city: city
        )
    }

    private static func makeController() -> TeamsViewController {
        makeController(teams: [
            team(254, "The Cheesy Poofs"), team(2590, "Nemesis"), team(1114, "Simbotics"),
        ])
    }

    private static func makeController(teams: [TeamSimple]) -> TeamsViewController {
        let api = MockTBAAPI()
        api.teams = teams
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

        controller.searchBar.text = "254"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 1) == [254])

        controller.searchBar.text = "25"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 2) == [254, 2590])

        controller.searchBar.text = ""
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 3) == [254, 1114, 2590])
    }

    @Test func matchesNickname() async {
        let controller = Self.makeController()
        controller.refresh()
        _ = await Self.waitForTeams(controller, count: 3)

        controller.searchBar.text = "nemesis"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 1) == [2590])
    }

    @Test func matchesNumbersFromTheFirstDigit() async {
        let controller = Self.makeController(teams: [
            Self.team(254, "The Cheesy Poofs"), Self.team(1254, "Iron Lions"),
            Self.team(2590, "Nemesis"),
        ])
        controller.refresh()
        _ = await Self.waitForTeams(controller, count: 3)

        controller.searchBar.text = "25"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 2) == [254, 2590])
    }

    @Test func ignoresCaseAccentsAndSurroundingSpaces() async {
        let controller = Self.makeController(teams: [
            Self.team(254, "The Cheesy Poofs"),
            Self.team(1860, "Alphabots", city: "São José dos Campos"),
        ])
        controller.refresh()
        _ = await Self.waitForTeams(controller, count: 2)

        controller.searchBar.text = "SAO JOSE"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 1) == [1860])

        controller.searchBar.text = ""
        controller.updateDataSource()
        controller.searchBar.text = "poofs "
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 1) == [254])
    }

    @Test func ignoresTheOfficialName() async {
        let controller = Self.makeController(teams: [
            Self.team(
                1114,
                "Simbotics",
                name: "General Motors Canada & Governor Simcoe Secondary School"
            ),
            Self.team(2590, "Nemesis"),
        ])
        controller.refresh()
        _ = await Self.waitForTeams(controller, count: 2)

        controller.searchBar.text = "secondary"
        controller.updateDataSource()
        #expect(await Self.waitForTeams(controller, count: 0) == [])
    }

    @Test func everyTeamListShowsTheFilter() {
        let dependencies = Dependencies.mock()
        let teams = TeamsContainerViewController(dependencies: dependencies).teamsViewController
        let eventTeams = EventTeamsViewController(eventKey: "2026casj", dependencies: dependencies)
        let districtTeams = DistrictTeamsViewController(
            districtKey: "2026fim",
            year: 2026,
            dependencies: dependencies
        )
        let lists: [(list: TBATableViewController, searchBar: UISearchBar)] = [
            (teams, teams.searchBar),
            (eventTeams, eventTeams.searchBar),
            (districtTeams, districtTeams.searchBar),
        ]
        for (list, searchBar) in lists {
            list.loadViewIfNeeded()
            #expect(list.containerAccessoryView === searchBar)
            #expect(searchBar.placeholder == "Search Teams")
        }
    }

}
