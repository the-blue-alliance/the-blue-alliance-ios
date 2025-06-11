import SwiftUI
import TBAAPI
import UIKit

@MainActor protocol RootController {
    var dependencyProvider: DependencyProvider! { get }
}

enum RootType: String, CaseIterable {
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

    @MainActor
    func viewController(dependencyProvider: DependencyProvider) -> UIViewController {
        let viewController: UIViewController = {
            switch self {
            case .events:
                let eventsViewController = SeasonEventsViewController(
                    dependencyProvider: dependencyProvider
                )
                eventsViewController.title = title
                return UINavigationController(rootViewController: eventsViewController)
            case .teams:
                let teamsViewController = TeamsViewController(
                    dependencyProvider: dependencyProvider
                )
                teamsViewController.title = title
                return UINavigationController(rootViewController: teamsViewController)
            case .districts:
                let districtsViewController = DistrictsViewController(
                    dependencyProvider: dependencyProvider
                )
                districtsViewController.title = title
                return UINavigationController(rootViewController: districtsViewController)
            default:
                return UIViewController()
            }
        }()
        return viewController
    }

}

class Dependencies: ObservableObject, Observable {
    @Published var api: TBAAPI
    @Published var statusService: StatusService

    init(api: TBAAPI, statusService: StatusService) {
        self.api = api
        self.statusService = statusService
    }
}
