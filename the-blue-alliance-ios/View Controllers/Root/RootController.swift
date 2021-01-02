import CoreData
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit

protocol RootChildController {
    var rootType: RootType { get }
}

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

    var supportsPush: Bool {
        // Settings is currently the only VC that doesn't support a sub-menu push
        return self != .settings
    }

}

protocol RootController {
    var authDelegate: AuthDelegate { get }
    var fcmTokenProvider: FCMTokenProvider { get }
    var myTBA: MyTBA { get }
    var pasteboard: UIPasteboard? { get }
    var photoLibrary: PHPhotoLibrary? { get }
    var pushService: PushService { get }
    var searchService: SearchService { get }
    var urlOpener: URLOpener { get }
    var statusService: StatusService { get }
    var dependencies: Dependencies { get }

    // MARK: - Handoff Methods
    func continueSearch(_ searchText: String) -> Bool

    func show(event: Event) -> Bool
    func show(team: Team) -> Bool
}

extension RootController {

    var eventsViewController: EventsContainerViewController {
        return EventsContainerViewController(myTBA: myTBA,
                                             pasteboard: pasteboard,
                                             photoLibrary: photoLibrary,
                                             searchService: searchService,
                                             statusService: statusService,
                                             urlOpener: urlOpener,
                                             dependencies: dependencies)
    }

    var teamsViewController: TeamsContainerViewController {
        return TeamsContainerViewController(myTBA: myTBA,
                                            pasteboard: pasteboard,
                                            photoLibrary: photoLibrary,
                                            searchService: searchService,
                                            statusService: statusService,
                                            urlOpener: urlOpener,
                                            dependencies: dependencies)
    }

    var districtsViewController: DistrictsContainerViewController {
        return DistrictsContainerViewController(myTBA: myTBA,
                                                statusService: statusService,
                                                urlOpener: urlOpener,
                                                dependencies: dependencies)
    }

    var settingsViewController: SettingsViewController {
        return SettingsViewController(fcmTokenProvider: fcmTokenProvider,
                                      myTBA: myTBA,
                                      pushService: pushService,
                                      searchService: searchService,
                                      urlOpener: urlOpener,
                                      dependencies: dependencies)
    }

    var myTBAViewController: MyTBAViewController {
        return MyTBAViewController(authDelegate: authDelegate,
                                   fcmTokenProvider: fcmTokenProvider,
                                   myTBA: myTBA,
                                   statusService: statusService,
                                   urlOpener: urlOpener,
                                   dependencies: dependencies)
    }

}
