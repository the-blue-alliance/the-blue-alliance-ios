import Foundation
import MyTBAKit
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct MyTBATableViewControllerTests {

    private static func team(_ number: Int, nickname: String = "") -> Team {
        Team(key: "frc\(number)", teamNumber: number, nickname: nickname, name: "")
    }

    private static func event(key: String, startDate: String, endDate: String) -> Event {
        Event(
            key: key,
            name: "",
            eventCode: String(key.dropFirst(4)),
            eventType: ._0,
            startDate: startDate,
            endDate: endDate,
            year: Int(key.prefix(4)) ?? 0,
            eventTypeString: "",
            webcasts: [],
            divisionKeys: []
        )
    }

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


    private static func waitForSections(_ controller: MyTBATableViewController, count: Int) async -> Int {
        for _ in 0..<200 where controller.tableView.numberOfSections != count {
            try? await Task.sleep(for: .milliseconds(10))
        }
        return controller.tableView.numberOfSections
    }

    /// The signed-in path: a remote refresh writes the store, which loads every
    /// backing model and renders an Events section above a Teams section.
    @Test func signedInRefreshRendersEventsAndTeams() async {
        let api = MockTBAAPI()
        api.teamsByKey["frc254"] = Self.team(254, nickname: "The Cheesy Poofs")
        api.teamsByKey["frc1114"] = Self.team(1114, nickname: "Simbotics")
        api.eventsByKey["2026casj"] = Self.event(
            key: "2026casj", startDate: "2026-03-01", endDate: "2026-03-03"
        )
        api.eventsByKey["2026miket"] = Self.event(
            key: "2026miket", startDate: "2026-04-01", endDate: "2026-04-03"
        )

        let dependencies = Dependencies.mock(api: api)
        let auth = dependencies.authService as! MockAuthService
        auth.isSignedIn = true
        let myTBA = dependencies.myTBA as! MockSessionMyTBA
        myTBA.favorites = [
            MyTBAFavorite(modelKey: "frc254", modelType: .team),
            MyTBAFavorite(modelKey: "2026casj", modelType: .event),
            MyTBAFavorite(modelKey: "frc1114", modelType: .team),
            MyTBAFavorite(modelKey: "2026miket", modelType: .event),
        ]

        let controller = MyTBAFavoritesViewController(dependencies: dependencies)
        controller.loadViewIfNeeded()
        controller.refresh()

        #expect(await Self.waitForRows(controller, count: 4) == 4)
        #expect(await Self.waitForSections(controller, count: 2) == 2)
    }

    /// Same path for subscriptions, which also carry match keys myTBA can't render.
    @Test func signedInSubscriptionsRefreshSkipsUnrenderableTypes() async {
        let api = MockTBAAPI()
        api.teamsByKey["frc7332"] = Self.team(7332)
        let dependencies = Dependencies.mock(api: api)
        (dependencies.authService as! MockAuthService).isSignedIn = true
        let myTBA = dependencies.myTBA as! MockSessionMyTBA
        myTBA.subscriptions = [
            MyTBASubscription(modelKey: "frc7332", modelType: .team, notifications: [.matchScore]),
            MyTBASubscription(
                modelKey: "2026casj_qm1", modelType: .match, notifications: [.matchScore]
            ),
        ]

        let controller = MyTBASubscriptionsViewController(dependencies: dependencies)
        controller.loadViewIfNeeded()
        controller.refresh()

        #expect(await Self.waitForRows(controller, count: 1) == 1)
    }


    /// The real shape: signed in, hosted in a window, with an API that fails
    /// every model load so the failure banner path runs too.
    @Test func signedInMyTBAViewInAWindowLoadsFavorites() async {
        let api = MockTBAAPI()
        api.teamsByKey["frc254"] = Self.team(254, nickname: "The Cheesy Poofs")
        api.eventsByKey["2026casj"] = Self.event(
            key: "2026casj", startDate: "2026-03-01", endDate: "2026-03-03"
        )
        let dependencies = Dependencies.mock(api: api)
        (dependencies.authService as! MockAuthService).isSignedIn = true
        let myTBA = dependencies.myTBA as! MockSessionMyTBA
        myTBA.favorites = [
            MyTBAFavorite(modelKey: "frc254", modelType: .team),
            MyTBAFavorite(modelKey: "2026casj", modelType: .event),
            // Nothing stubbed for these, so their loads fail and the banner shows.
            MyTBAFavorite(modelKey: "frc1114", modelType: .team),
            MyTBAFavorite(modelKey: "2026miket", modelType: .event),
        ]
        myTBA.subscriptions = myTBA.favorites.map {
            MyTBASubscription(modelKey: $0.modelKey, modelType: $0.modelType, notifications: [])
        }

        let controller = MyTBAViewController(dependencies: dependencies)
        let navigation = UINavigationController(rootViewController: controller)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        window.layoutIfNeeded()

        let favorites = controller.favoritesViewController
        #expect(await Self.waitForRows(favorites, count: 2) == 2)
        window.layoutIfNeeded()

        // Switch to Subscriptions the way the segmented control does.
        controller.subscriptionsViewController.refresh()
        #expect(await Self.waitForRows(controller.subscriptionsViewController, count: 2) == 2)
        window.layoutIfNeeded()
    }


    /// A big favorites list where only some models load, then the user taps the
    /// failure banner so loaded and key-only rows are sorted together.
    @Test func manyFavoritesWithSomeFailuresRenderAfterTappingTheBanner() async {
        let api = MockTBAAPI()
        let numbers = Array(1...60)
        // Only the even-numbered teams resolve; the odd ones fail to load.
        for number in numbers where number.isMultiple(of: 2) {
            api.teamsByKey["frc\(number)"] = Self.team(number)
        }
        let dependencies = Dependencies.mock(api: api)
        (dependencies.authService as! MockAuthService).isSignedIn = true
        let myTBA = dependencies.myTBA as! MockSessionMyTBA
        myTBA.favorites = numbers.map { MyTBAFavorite(modelKey: "frc\($0)", modelType: .team) }

        let controller = MyTBAFavoritesViewController(dependencies: dependencies)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.refresh()

        #expect(await Self.waitForRows(controller, count: 30) == 30)

        controller.bannerTapped()
        #expect(Self.rows(in: controller.tableView) == 60)
        window.layoutIfNeeded()
    }


    /// A returning signed-in user: the store is already populated off disk before
    /// the view exists, so the first snapshot, the observation's first emit, and
    /// the pull-to-refresh all load models at once.
    @Test func returningSignedInUserWithAPopulatedStore() async {
        let api = MockTBAAPI()
        api.teamsByKey["frc254"] = Self.team(254, nickname: "The Cheesy Poofs")
        api.teamsByKey["frc1114"] = Self.team(1114, nickname: "Simbotics")
        api.eventsByKey["2026casj"] = Self.event(
            key: "2026casj", startDate: "2026-03-01", endDate: "2026-03-03"
        )
        let dependencies = Dependencies.mock(api: api)
        (dependencies.authService as! MockAuthService).isSignedIn = true

        let favorites = [
            MyTBAFavorite(modelKey: "frc254", modelType: .team),
            MyTBAFavorite(modelKey: "frc1114", modelType: .team),
            MyTBAFavorite(modelKey: "2026casj", modelType: .event),
        ]
        // As if it had been read back off disk at launch.
        dependencies.myTBAStores.favorites.replaceAll(with: favorites)
        (dependencies.myTBA as! MockSessionMyTBA).favorites = favorites

        let controller = MyTBAViewController(dependencies: dependencies)
        let navigation = UINavigationController(rootViewController: controller)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        window.layoutIfNeeded()

        #expect(await Self.waitForRows(controller.favoritesViewController, count: 3) == 3)
        window.layoutIfNeeded()
    }


    /// Refreshes that overlap the way they do on a real network: the user lands
    /// on myTBA, pulls to refresh, and flips between segments while loads are
    /// still in flight.
    @Test func overlappingRefreshesWhileSwitchingSegments() async {
        let api = MockTBAAPI()
        api.latency = .milliseconds(20)
        let numbers = Array(1...20)
        for number in numbers {
            api.teamsByKey["frc\(number)"] = Self.team(number)
        }
        for year in 2024...2026 {
            api.eventsByKey["\(year)casj"] = Self.event(
                key: "\(year)casj", startDate: "\(year)-03-01", endDate: "\(year)-03-03"
            )
        }

        let dependencies = Dependencies.mock(api: api)
        (dependencies.authService as! MockAuthService).isSignedIn = true
        let myTBA = dependencies.myTBA as! MockSessionMyTBA
        myTBA.favorites =
            numbers.map { MyTBAFavorite(modelKey: "frc\($0)", modelType: .team) }
            + (2024...2026).map { MyTBAFavorite(modelKey: "\($0)casj", modelType: .event) }
        myTBA.subscriptions = myTBA.favorites.map {
            MyTBASubscription(modelKey: $0.modelKey, modelType: $0.modelType, notifications: [])
        }

        let controller = MyTBAViewController(dependencies: dependencies)
        let navigation = UINavigationController(rootViewController: controller)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        window.layoutIfNeeded()

        // Hammer both children the way the segmented control and pull-to-refresh do.
        for _ in 0..<8 {
            controller.favoritesViewController.refresh()
            controller.subscriptionsViewController.refresh()
            controller.beginAppearanceTransition(true, animated: false)
            controller.endAppearanceTransition()
            window.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(5))
        }

        #expect(await Self.waitForRows(controller.favoritesViewController, count: 23) == 23)
        window.layoutIfNeeded()
    }

    /// Sign-out while a refresh is in flight, which cancels both children and
    /// flips every screen back to the signed-out interface.
    @Test func signOutWhileRefreshing() async {
        let api = MockTBAAPI()
        api.latency = .milliseconds(30)
        for number in 1...10 {
            api.teamsByKey["frc\(number)"] = Self.team(number)
        }
        let dependencies = Dependencies.mock(api: api)
        let auth = dependencies.authService as! MockAuthService
        auth.isSignedIn = true
        let myTBA = dependencies.myTBA as! MockSessionMyTBA
        myTBA.favorites = (1...10).map { MyTBAFavorite(modelKey: "frc\($0)", modelType: .team) }

        let controller = MyTBAViewController(dependencies: dependencies)
        let navigation = UINavigationController(rootViewController: controller)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        window.layoutIfNeeded()

        controller.favoritesViewController.refresh()
        try? await Task.sleep(for: .milliseconds(10))

        try? await dependencies.myTBASession.signOut()
        controller.authStateChanged(isSignedIn: false)
        window.layoutIfNeeded()

        #expect(await Self.waitForRows(controller.favoritesViewController, count: 0) == 0)
    }


    private static func teamNumbers(in controller: MyTBATableViewController) -> [String] {
        let table = controller.tableView
        return (0..<table.numberOfRows(inSection: 0)).compactMap {
            let cell = table.dataSource?.tableView(table, cellForRowAt: IndexPath(row: $0, section: 0))
            return (cell as? TeamTableViewCell)?.viewModel?.teamNumber
        }
    }

    /// Placeholder rows have to stay in team-number order alongside loaded ones.
    /// Ordering them as strings instead put 1114 after 254, which is both wrong
    /// and not a strict weak ordering for `sorted`.
    @Test func placeholderTeamsSortByNumberAlongsideLoadedTeams() async {
        let api = MockTBAAPI()
        // 254 and 1500 load; 1114 does not, so it renders as a placeholder.
        api.teamsByKey["frc254"] = Self.team(254)
        api.teamsByKey["frc1500"] = Self.team(1500)
        let dependencies = Dependencies.mock(api: api)
        (dependencies.authService as! MockAuthService).isSignedIn = true
        let myTBA = dependencies.myTBA as! MockSessionMyTBA
        myTBA.favorites = [254, 1114, 1500].map {
            MyTBAFavorite(modelKey: "frc\($0)", modelType: .team)
        }

        let controller = MyTBAFavoritesViewController(dependencies: dependencies)
        controller.loadViewIfNeeded()
        controller.refresh()

        #expect(await Self.waitForRows(controller, count: 2) == 2)
        controller.bannerTapped()
        #expect(Self.rows(in: controller.tableView) == 3)
        #expect(Self.teamNumbers(in: controller) == ["254", "1114", "1500"])
    }

}
