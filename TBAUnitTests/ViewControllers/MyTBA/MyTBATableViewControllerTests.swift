import Foundation
import MyTBAKit
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct MyTBATableViewControllerTests {

    private static func rows(in table: UITableView) -> Int {
        (0..<table.numberOfSections).reduce(0) { $0 + table.numberOfRows(inSection: $1) }
    }

    /// Store changes arrive through `Observations`, a tick after the mutation.
    private static func waitForRows(_ controller: MyTBATableViewController, count: Int) async -> Int {
        for _ in 0..<200 where rows(in: controller.tableView) != count {
            try? await Task.sleep(for: .milliseconds(10))
        }
        return rows(in: controller.tableView)
    }

    @Test func favoritesTableFollowsTheStore() async {
        let api = MockTBAAPI()
        for (key, number, name) in [("frc254", 254, "The Cheesy Poofs"), ("frc1114", 1114, "Simbotics")] {
            api.teamsByKey[key] = Team(key: key, teamNumber: number, nickname: name, name: name)
        }
        let dependencies = Dependencies.mock(api: api)
        let controller = MyTBAFavoritesViewController(dependencies: dependencies)
        controller.loadViewIfNeeded()
        #expect(Self.rows(in: controller.tableView) == 0)

        // A row appears once the store changes *and* the item's model has loaded.
        let store = dependencies.myTBAStores.favorites
        store.upsert(MyTBAFavorite(modelKey: "frc254", modelType: .team))
        #expect(await Self.waitForRows(controller, count: 1) == 1)

        store.upsert(MyTBAFavorite(modelKey: "frc1114", modelType: .team))
        #expect(await Self.waitForRows(controller, count: 2) == 2)

        store.clear()
        #expect(await Self.waitForRows(controller, count: 0) == 0)
    }

}
