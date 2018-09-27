import Foundation
import UIKit
import CoreData
import TBAKit
import FirebaseRemoteConfig

class EventsContainerViewController: ContainerViewController {

    private let remoteConfig: RemoteConfig
    private let urlOpener: URLOpener
    private let userDefaults: UserDefaults

    private var year: Int
    private var eventsViewController: WeekEventsViewController!

    override var viewControllers: [ContainableViewController] {
        return [eventsViewController]
    }

    // MARK: - Init

    init(remoteConfig: RemoteConfig, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.remoteConfig = remoteConfig
        self.urlOpener = urlOpener
        self.userDefaults = userDefaults

        year = remoteConfig.currentSeason

        super.init(persistentContainer: persistentContainer)

        title = "Events"
        tabBarItem.image = UIImage(named: "ic_event")
        navigationTitleDelegate = self

        eventsViewController = WeekEventsViewController(year: year, persistentContainer: persistentContainer)
        eventsViewController.delegate = self
        eventsViewController.weekEventsDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // setupWeeks()
        updateInterface()
    }

    // MARK: - Private Methods

    private func updateInterface() {
        if let weekEvent = eventsViewController.weekEvent {
            navigationTitle = "\(weekEvent.weekString) Events"
        } else {
            navigationTitle = "---- Events"
        }
        navigationSubtitle = "▾ \(year)"
    }

}

extension EventsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        let yearSelectViewController = YearSelectViewController(year: year,
                                                                years: Array(1992...remoteConfig.maxSeason).reversed(),
                                                                week: eventsViewController.weekEvent,
                                                                persistentContainer: persistentContainer)
        yearSelectViewController.delegate = self

        let nav = UINavigationController(rootViewController: yearSelectViewController)
        navigationController?.present(nav, animated: true, completion: nil)
    }

}

extension EventsContainerViewController: YearSelectViewControllerDelegate {

    func weekEventSelected(_ weekEvent: Event) {
        year = Int(weekEvent.year)
        eventsViewController.weekEvent = weekEvent
    }

}

extension EventsContainerViewController: WeekEventsDelegate {

    func weekEventUpdated() {
        DispatchQueue.main.async {
            self.updateInterface()
        }
    }

}

extension EventsContainerViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

}
