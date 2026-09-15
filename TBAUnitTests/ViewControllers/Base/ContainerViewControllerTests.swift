import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct ContainerViewControllerTests {

    private final class StubTab: TBATableViewController, Refreshable {
        var barButtonItems: [UIBarButtonItem] = []
        var accessoryView: UIView?
        private(set) var refreshCount = 0

        override var additionalRightBarButtonItems: [UIBarButtonItem] { barButtonItems }

        override var containerAccessoryView: UIView? { accessoryView }

        var isDataSourceEmpty: Bool { false }

        func refresh() {
            refreshCount += 1
        }
    }

    private struct Harness {
        let first: StubTab
        let second: StubTab
        let container: ContainerViewController

        init(firstAccessoryView: UIView? = nil) {
            let dependencies = Dependencies.mock()
            first = StubTab(dependencies: dependencies)
            second = StubTab(dependencies: dependencies)
            container = ContainerViewController(
                viewControllers: [first, second],
                navigationTitle: "Title",
                segmentedControlTitles: ["First", "Second"],
                dependencies: dependencies
            )
            first.accessoryView = firstAccessoryView
            container.loadViewIfNeeded()
            container.beginAppearanceTransition(true, animated: false)
            container.endAppearanceTransition()
        }
    }

    @Test func onlyTheSelectedTabLoads() {
        let harness = Harness()

        #expect(harness.first.parent === harness.container)
        #expect(harness.first.refreshCount == 1)
        #expect(harness.second.parent == nil)
        #expect(!harness.second.isViewLoaded)
    }

    @Test func aScreenOutsideAContainerRefreshesItself() {
        let screen = StubTab(dependencies: Dependencies.mock())
        screen.loadViewIfNeeded()
        screen.beginAppearanceTransition(true, animated: false)
        screen.endAppearanceTransition()

        #expect(screen.tableView.refreshControl != nil)
        #expect(screen.refreshCount == 1)
    }

    @Test func theSelectedTabsAccessoryIsPinnedAboveTheList() {
        let accessoryView = UIView()
        let harness = Harness(firstAccessoryView: accessoryView)

        let arrangedSubviews = harness.container.rootStackView.arrangedSubviews
        #expect(arrangedSubviews.contains(accessoryView))
        #expect(arrangedSubviews.firstIndex(of: accessoryView) == arrangedSubviews.count - 2)
    }

    @Test func aContainerWithOnlyATitleKeepsIt() {
        let dependencies = Dependencies.mock()
        let container = ContainerViewController(
            viewControllers: [StubTab(dependencies: dependencies)],
            dependencies: dependencies
        )
        container.title = "myTBA"
        container.loadViewIfNeeded()
        container.updatePropertiesIfNeeded()

        #expect(container.navigationItem.title == "myTBA")
    }

    @Test func navigationItemFollowsTheContainerAndItsSelectedTab() {
        let harness = Harness()
        let containerItem = UIBarButtonItem(systemItem: .add)
        let tabItem = UIBarButtonItem(systemItem: .search)
        harness.first.barButtonItems = [tabItem]

        harness.container.navigationTitle = "Updated"
        harness.container.navigationSubtitle = "Subtitle"
        harness.container.rightBarButtonItems = [containerItem]
        harness.container.updatePropertiesIfNeeded()

        let navigationItem = harness.container.navigationItem
        #expect(navigationItem.title == "Updated")
        #expect(navigationItem.subtitle == "Subtitle")
        #expect(navigationItem.rightBarButtonItems == [containerItem, tabItem])
    }

}
