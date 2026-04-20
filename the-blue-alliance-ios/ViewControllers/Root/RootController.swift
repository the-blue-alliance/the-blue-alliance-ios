import Foundation
import MyTBAKit
import UIKit

enum RootType: CaseIterable {
    case events
    case teams
    case districts
    case myTBA
    case settings

    var title: String {
        switch self {
        case .events:
            return "Events"
        case .teams:
            return "Teams"
        case .districts:
            return "Districts"
        case .myTBA:
            return "myTBA"
        case .settings:
            return "Settings"
        }
    }

    var icon: UIImage? {
        switch self {
        case .events:
            return UIImage.eventIcon
        case .teams:
            return UIImage.teamIcon
        case .districts:
            return UIImage.districtIcon
        case .myTBA:
            return UIImage.starIcon
        case .settings:
            return UIImage.settingsIcon
        }
    }

}

protocol RootController {
    var dependencies: Dependencies { get }
    var fcmTokenProvider: any FCMTokenProvider { get }
    var pushService: any PushServiceProtocol { get }
}

extension RootController {

    var eventsViewController: EventsContainerViewController {
        return EventsContainerViewController(dependencies: dependencies)
    }

    var teamsViewController: TeamsContainerViewController {
        return TeamsContainerViewController(dependencies: dependencies)
    }

    var districtsViewController: DistrictsContainerViewController {
        return DistrictsContainerViewController(dependencies: dependencies)
    }

    var settingsViewController: SettingsViewController {
        return SettingsViewController(
            fcmTokenProvider: fcmTokenProvider,
            pushService: pushService,
            dependencies: dependencies
        )
    }

    var myTBAViewController: MyTBAViewController {
        return MyTBAViewController(dependencies: dependencies)
    }

}
