import Foundation
import MyTBAKit
import UIKit

enum RootType: CaseIterable {
    case dashboard
    case events
    case teams
    case districts
    case myTBA
    case settings

    var title: String {
        switch self {
        case .dashboard:
            return "Home"
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
        case .dashboard:
            return UIImage.homeIcon
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

    var tabIdentifier: String {
        switch self {
        case .dashboard:
            return "tab.dashboard"
        case .events:
            return "tab.events"
        case .teams:
            return "tab.teams"
        case .districts:
            return "tab.districts"
        case .myTBA:
            return "tab.mytba"
        case .settings:
            return "tab.settings"
        }
    }

    // Dashboard takes the Teams slot; teams are reachable through search.
    static func tabs(dashboardEnabled: Bool) -> [RootType] {
        if dashboardEnabled {
            return [.dashboard, .events, .districts, .myTBA, .settings]
        }
        return [.events, .teams, .districts, .myTBA, .settings]
    }

}

protocol RootController {
    var dependencies: Dependencies { get }
    var fcmTokenProvider: any FCMTokenProvider { get }
    var pushService: any PushServiceProtocol { get }
}

extension RootController {

    var dashboardViewController: DashboardContainerViewController {
        return DashboardContainerViewController(dependencies: dependencies)
    }

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

    func makeRootViewController(for type: RootType) -> UIViewController {
        switch type {
        case .dashboard:
            return dashboardViewController
        case .events:
            return eventsViewController
        case .teams:
            return teamsViewController
        case .districts:
            return districtsViewController
        case .myTBA:
            return myTBAViewController
        case .settings:
            return settingsViewController
        }
    }

}
