import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class EventsContainerViewController: ContainerViewController {

    private(set) var eventsViewController: WeekEventsViewController

    var searchController: UISearchController!

    // MARK: - Init

    init(dependencies: Dependencies) {
        let initialYear = dependencies.statusService.currentSeason
        eventsViewController = WeekEventsViewController(
            year: initialYear,
            dependencies: dependencies
        )

        super.init(
            viewControllers: [eventsViewController],
            navigationTitle: EventsContainerViewController.eventsTitle(
                eventsViewController.weekEvent
            ),
            navigationSubtitle: ContainerViewController.yearSubtitle(initialYear),
            dependencies: dependencies
        )

        // TODO: We should be able to move this somewhere else and DRY this code
        title = RootType.events.title
        tabBarItem.image = RootType.events.icon

        navigationTitleDelegate = self
        eventsViewController.delegate = self
        eventsViewController.weekEventsDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Events: \(year)")
    }

    // MARK: - Private Methods

    private var year: Int {
        eventsViewController.weekEvent?.year ?? dependencies.statusService.currentSeason
    }

    private static func eventsTitle(_ event: Event?) -> String {
        if let event = event {
            return "\(event.weekString) Events"
        } else {
            return "---- Events"
        }
    }

    private func updateInterface() {
        navigationTitle = EventsContainerViewController.eventsTitle(eventsViewController.weekEvent)
        navigationSubtitle = ContainerViewController.yearSubtitle(year)
    }

}

extension EventsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        let yearSelectViewController = YearSelectViewController(
            year: year,
            years: Array(1992...statusService.maxSeason).reversed(),
            week: eventsViewController.weekEvent,
            dependencies: dependencies
        )
        yearSelectViewController.delegate = self

        let nav = UINavigationController(rootViewController: yearSelectViewController)
        nav.modalPresentationStyle = .formSheet
        navigationController?.present(nav, animated: true, completion: nil)
    }

}

extension EventsContainerViewController: YearSelectViewControllerDelegate {

    func weekEventSelected(_ weekEvent: Event) {
        eventsViewController.weekEvent = weekEvent
    }

}

extension EventsContainerViewController: WeekEventsDelegate {

    func weekEventUpdated() {
        updateInterface()
    }

}

extension EventsContainerViewController: SearchContainer, SearchContainerDelegate,
    SearchViewControllerDelegate
{}

// MARK: - EventsListViewControllerDelegate

extension EventsContainerViewController: EventsListViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, dependencies: dependencies)
        navigationController?.pushViewController(eventViewController, animated: true)
    }
}
