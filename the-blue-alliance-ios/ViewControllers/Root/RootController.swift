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
    case more
    case search

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
        case .more:
            return "More"
        case .search:
            return "Search"
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
        case .more:
            return UIImage(systemName: "ellipsis")
        case .search:
            return UIImage(systemName: "magnifyingglass")
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
        case .more:
            return "tab.more"
        case .search:
            return "tab.search"
        }
    }

    // Search is last so the tab bar renders it as its own trailing pill. On iPhone the bar
    // has five slots and the pill is not exempt from overflow, so at most four tabs sit
    // beside it. Everything else lives behind our own More tab, which keeps the count fixed
    // no matter how many sections are added. Which four make the bar in dashboard mode is a
    // product call; for now Dashboard takes myTBA's slot.
    static func tabs(dashboardEnabled: Bool) -> [RootType] {
        if dashboardEnabled {
            return [.dashboard, .events, .districts, .more, .search]
        }
        return [.events, .districts, .myTBA, .more, .search]
    }

    static func moreItems(dashboardEnabled: Bool) -> [RootType] {
        if dashboardEnabled {
            return [.teams, .myTBA, .settings]
        }
        return [.teams, .settings]
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

    var searchViewController: SearchContainerViewController {
        return SearchContainerViewController(dependencies: dependencies)
    }

    var moreViewController: MoreViewController {
        let dashboardEnabled = dependencies.appSettings.featureFlags.isEnabled(.dashboard)
        return MoreViewController(items: RootType.moreItems(dashboardEnabled: dashboardEnabled)) {
            self.makeRootViewController(for: $0)
        }
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
        case .more:
            return moreViewController
        case .search:
            return searchViewController
        }
    }

}
