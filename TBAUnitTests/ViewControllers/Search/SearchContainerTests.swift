import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct SearchContainerTests {

    /// The search tab's container, loaded inside the same tab bar and navigation controller
    /// hierarchy the app uses.
    private final class Harness {
        let window: UIWindow
        let container: SearchContainerViewController

        init() {
            container = SearchContainerViewController(dependencies: .mock())
            window = UIWindow.makeForTesting()
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [
                UINavigationController(rootViewController: container)
            ]
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
            container.loadViewIfNeeded()
            window.layoutIfNeeded()
        }
    }

    @Test func searchFieldIsLeftToTheSearchTabAndResultsShowInPlace() {
        let harness = Harness()
        let navigationItem = harness.container.navigationItem

        let searchController = try? #require(navigationItem.searchController)
        #expect(searchController?.searchResultsController == nil)
        #expect(searchController?.searchResultsUpdater is SearchViewController)
        #expect(navigationItem.preferredSearchBarPlacement == .automatic)
    }

}
