import Foundation
import UIKit

class PhoneRootViewController: UITabBarController, RootController {

    let dependencies: Dependencies
    let pushService: any PushServiceProtocol

    init(
        pushService: any PushServiceProtocol,
        dependencies: Dependencies
    ) {
        self.dependencies = dependencies
        self.pushService = pushService

        super.init(nibName: nil, bundle: nil)

        let dashboardEnabled = dependencies.appSettings.featureFlags.isEnabled(.dashboard)
        tabs = RootType.tabs(dashboardEnabled: dashboardEnabled).map { type in
            let provider: (UITab) -> UIViewController = { [unowned self] _ in
                UINavigationController(rootViewController: self.makeRootViewController(for: type))
            }
            guard type == .search else {
                return UITab(
                    title: type.title,
                    image: type.icon,
                    identifier: type.tabIdentifier,
                    viewControllerProvider: provider
                )
            }
            // Tapping the pill opens the field straight away, and cancelling returns to the
            // tab that was showing before.
            let searchTab = UISearchTab(viewControllerProvider: provider)
            searchTab.automaticallyActivatesSearch = true
            return searchTab
        }

        mode = .tabSidebar
        tabBarMinimizeBehavior = .onScrollDown
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Every tab sits under the blue bar, so the root owns the style. Deferring to the tab's
    // navigation controller would pick dark text from its default bar style.
    override var childForStatusBarStyle: UIViewController? { nil }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

}
