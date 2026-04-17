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

        let deps = dependencies
        let fcm = fcmTokenProvider
        let push = pushService

        tabs = [
            UITab(title: RootType.events.title, image: RootType.events.icon, identifier: "events") { _ in
                UINavigationController(rootViewController: EventsContainerViewController(dependencies: deps))
            },
            UITab(title: RootType.teams.title, image: RootType.teams.icon, identifier: "teams") { _ in
                UINavigationController(rootViewController: TeamsContainerViewController(dependencies: deps))
            },
            UITab(title: RootType.districts.title, image: RootType.districts.icon, identifier: "districts") { _ in
                UINavigationController(rootViewController: DistrictsContainerViewController(dependencies: deps))
            },
            UITab(title: RootType.myTBA.title, image: RootType.myTBA.icon, identifier: "myTBA") { _ in
                UINavigationController(rootViewController: MyTBAViewController(dependencies: deps))
            },
            UITab(title: RootType.settings.title, image: RootType.settings.icon, identifier: "settings") { _ in
                UINavigationController(rootViewController: SettingsViewController(fcmTokenProvider: fcm, pushService: push, dependencies: deps))
            }
        ]

        mode = .tabSidebar
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
