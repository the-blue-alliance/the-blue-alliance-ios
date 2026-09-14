import Foundation
import MyTBAKit
import UIKit

class PhoneRootViewController: UITabBarController, RootController {

    let dependencies: Dependencies
    let fcmTokenProvider: any FCMTokenProvider
    let pushService: any PushServiceProtocol

    init(
        fcmTokenProvider: any FCMTokenProvider,
        pushService: any PushServiceProtocol,
        dependencies: Dependencies
    ) {
        self.dependencies = dependencies
        self.fcmTokenProvider = fcmTokenProvider
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

}
