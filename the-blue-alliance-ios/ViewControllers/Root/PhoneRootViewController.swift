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
            UITab(title: type.title, image: type.icon, identifier: type.tabIdentifier) {
                [unowned self] _ in
                UINavigationController(rootViewController: self.makeRootViewController(for: type))
            }
        }

        mode = .tabSidebar
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
