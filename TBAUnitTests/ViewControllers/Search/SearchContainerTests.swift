import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct SearchContainerTests {

    /// A container whose search controller has gone through `setupSearchController()` inside a
    /// navigation controller and a window.
    ///
    /// The tab bar controller is load bearing. Without one the bar has room to place the search
    /// field inline, and UIKit swaps in its own SwiftUI-backed field. The app always hosts these
    /// containers inside the phone root tab bar controller, where the field stays stacked.
    private final class Harness {
        let window: UIWindow
        let container: TeamsContainerViewController

        init() {
            container = TeamsContainerViewController(dependencies: .mock())
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
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

    @Test func searchBarStaysStackedOnceTheNavigationItemAdoptsIt() {
        let harness = Harness()
        let navigationItem = harness.container.navigationItem

        #expect(navigationItem.searchController === harness.container.searchController)
        #expect(navigationItem.searchBarPlacement == .stacked)
        #expect(navigationItem.hidesSearchBarWhenScrolling == false)
    }

    @Test func resultsControllerIsTheSearchViewController() {
        let harness = Harness()

        #expect(
            harness.container.searchController.searchResultsController is SearchViewController
        )
    }

}
