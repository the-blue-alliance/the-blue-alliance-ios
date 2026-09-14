import Foundation
import MyTBAKit
import Testing
import UIKit

@testable import The_Blue_Alliance


@MainActor
struct PhoneRootViewControllerTests {

    private static func makeRoot(dashboardEnabled: Bool) -> PhoneRootViewController {
        let dependencies = Dependencies.mock()
        dependencies.appSettings.featureFlags.setEnabled(dashboardEnabled, for: .dashboard)
        return PhoneRootViewController(
            fcmTokenProvider: MockFCMTokenProvider(),
            pushService: MockPushService(),
            dependencies: dependencies
        )
    }

    @Test func flagOff_eventsLeadsAndSearchTrails() {
        let root = Self.makeRoot(dashboardEnabled: false)
        #expect(
            root.tabs.dropLast().map(\.identifier) == [
                "tab.events", "tab.districts", "tab.mytba", "tab.more",
            ]
        )
        #expect(root.tabs.last is UISearchTab)
    }

    @Test func flagOn_dashboardLeadsAndSearchTrails() {
        let root = Self.makeRoot(dashboardEnabled: true)
        #expect(
            root.tabs.dropLast().map(\.identifier) == [
                "tab.dashboard", "tab.events", "tab.districts", "tab.more",
            ]
        )
        #expect(root.tabs.last is UISearchTab)
        #expect(root.selectedTab?.identifier == "tab.dashboard")
    }

    @Test func flagOn_dashboardTabHostsTheContainer() {
        let root = Self.makeRoot(dashboardEnabled: true)
        let navigationController = root.selectedTab?.viewController as? UINavigationController
        #expect(navigationController?.viewControllers.first is DashboardContainerViewController)
    }

    @Test func searchTabHostsTheSearchContainer() {
        let root = Self.makeRoot(dashboardEnabled: false)
        let navigationController = root.tabs.last?.viewController as? UINavigationController
        #expect(navigationController?.viewControllers.first is SearchContainerViewController)
    }

    @Test func tabLists_matchTheRootTypeTable() {
        #expect(
            RootType.tabs(dashboardEnabled: false) == [
                .events, .districts, .myTBA, .more, .search,
            ]
        )
        #expect(
            RootType.tabs(dashboardEnabled: true) == [
                .dashboard, .events, .districts, .more, .search,
            ]
        )
        #expect(RootType.moreItems(dashboardEnabled: false) == [.teams, .settings])
        #expect(RootType.moreItems(dashboardEnabled: true) == [.teams, .myTBA, .settings])
    }

}
