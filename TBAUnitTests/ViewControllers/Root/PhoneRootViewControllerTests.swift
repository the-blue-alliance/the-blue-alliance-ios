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

    @Test func flagOff_keepsTheOriginalFiveTabs() {
        let root = Self.makeRoot(dashboardEnabled: false)
        #expect(
            root.tabs.map(\.identifier) == [
                "tab.events", "tab.teams", "tab.districts", "tab.mytba", "tab.settings",
            ]
        )
    }

    @Test func flagOn_dashboardLeadsAndTeamsIsDropped() {
        let root = Self.makeRoot(dashboardEnabled: true)
        #expect(
            root.tabs.map(\.identifier) == [
                "tab.dashboard", "tab.events", "tab.districts", "tab.mytba", "tab.settings",
            ]
        )
        #expect(root.selectedTab?.identifier == "tab.dashboard")
    }

    @Test func flagOn_dashboardTabHostsTheContainerWithSearch() {
        let root = Self.makeRoot(dashboardEnabled: true)
        let navigationController = root.selectedTab?.viewController as? UINavigationController
        let container =
            navigationController?.viewControllers.first as? DashboardContainerViewController
        #expect(container != nil)

        container?.loadViewIfNeeded()
        #expect(container?.navigationItem.searchController === container?.searchController)
        #expect(container?.navigationItem.hidesSearchBarWhenScrolling == false)
    }

    @Test func tabLists_matchTheRootTypeTable() {
        #expect(
            RootType.tabs(dashboardEnabled: false) == [
                .events, .teams, .districts, .myTBA, .settings,
            ]
        )
        #expect(
            RootType.tabs(dashboardEnabled: true) == [
                .dashboard, .events, .districts, .myTBA, .settings,
            ]
        )
    }

}
