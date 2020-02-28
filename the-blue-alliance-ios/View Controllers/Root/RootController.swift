import CoreData
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit

protocol RootController {
    var fcmTokenProvider: FCMTokenProvider { get }
    var myTBA: MyTBA { get }
    var pasteboard: UIPasteboard? { get }
    var photoLibrary: PHPhotoLibrary? { get }
    var pushService: PushService { get }
    var searchService: SearchService { get }
    var urlOpener: URLOpener { get }
    var statusService: StatusService { get }
    var persistentContainer: NSPersistentContainer { get }
    var tbaKit: TBAKit { get }
    var userDefaults: UserDefaults { get }

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
                                             persistentContainer: persistentContainer,
                                             tbaKit: tbaKit,
                                             userDefaults: userDefaults)
    }

    var teamsViewController: TeamsContainerViewController {
        return TeamsContainerViewController(myTBA: myTBA,
                                            pasteboard: pasteboard,
                                            photoLibrary: photoLibrary,
                                            searchService: searchService,
                                            statusService: statusService,
                                            urlOpener: urlOpener,
                                            persistentContainer: persistentContainer,
                                            tbaKit: tbaKit,
                                            userDefaults: userDefaults)
    }

    var districtsViewController: DistrictsContainerViewController {
        return DistrictsContainerViewController(myTBA: myTBA,
                                                statusService: statusService,
                                                urlOpener: urlOpener,
                                                persistentContainer: persistentContainer,
                                                tbaKit: tbaKit,
                                                userDefaults: userDefaults)
    }

    var settingsViewController: SettingsViewController {
        return SettingsViewController(fcmTokenProvider: fcmTokenProvider,
                                      myTBA: myTBA,
                                      pushService: pushService,
                                      searchService: searchService,
                                      urlOpener: urlOpener,
                                      persistentContainer: persistentContainer,
                                      tbaKit: tbaKit,
                                      userDefaults: userDefaults)
    }

    var myTBAViewController: MyTBAViewController {
        return MyTBAViewController(myTBA: myTBA,
                                   statusService: statusService,
                                   urlOpener: urlOpener,
                                   persistentContainer: persistentContainer,
                                   tbaKit: tbaKit,
                                   userDefaults: userDefaults)
    }

}
