import Foundation
import MyTBAKit
import UIKit

class PhoneRootViewController: UITabBarController, RootController {

    let dependencies: Dependencies
    let fcmTokenProvider: any FCMTokenProvider
    let pushService: any PushServiceProtocol

    init(fcmTokenProvider: any FCMTokenProvider, pushService: any PushServiceProtocol, dependencies: Dependencies) {
        self.dependencies = dependencies
        self.fcmTokenProvider = fcmTokenProvider
        self.pushService = pushService

        super.init(nibName: nil, bundle: nil)

        viewControllers = [eventsViewController, teamsViewController, districtsViewController, myTBAViewController, settingsViewController].compactMap({ (viewController) -> UIViewController? in
            return UINavigationController(rootViewController: viewController)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
