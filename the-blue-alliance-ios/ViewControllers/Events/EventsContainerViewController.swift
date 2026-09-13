import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit
import TBAUtils

class EventsContainerViewController: ContainerViewController {

    private(set) var eventsViewController: WeekEventsViewController

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
            dependencies: dependencies
        )

        // TODO: We should be able to move this somewhere else and DRY this code
        navigationItem.backButtonTitle = RootType.events.title
        tabBarItem.image = RootType.events.icon

        rightBarButtonItems = [ContainerViewController.makeBarButtonItem(yearButton)]
        eventsViewController.delegate = self
        eventsViewController.weekEventsDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Methods

    override func viewDidLoad() {
        super.viewDidLoad()

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
        yearButton.configuration?.title = String(year)
    }

    // Years as submenus, each loading its weeks when opened, the way the old modal did in
    // two screens.
    private lazy var yearButton: UIButton = {
        let years = Array(1992...statusService.maxSeason).reversed()
        let menu = UIMenu(
            children: years.map { year in
                UIMenu(
                    title: String(year),
                    children: [
                        UIDeferredMenuElement.uncached { [weak self] completion in
                            self?.loadWeekActions(for: year, completion: completion)
                        }
                    ]
                )
            }
        )
        let button = ContainerViewController.makeMenuButton(menu: menu)
        button.configuration?.title = String(year)
        return button
    }()

    private func loadWeekActions(for year: Int, completion: @escaping ([UIMenuElement]) -> Void) {
        Task { [weak self] in
            guard let self else { return }
            let events = (try? await self.dependencies.api.eventsByYear(year)) ?? []
            let weeks = WeekEventsGrouping.weekEvents(for: year, from: events)
            guard !weeks.isEmpty else {
                completion([UIAction(title: "No weeks", attributes: .disabled) { _ in }])
                return
            }
            let currentKey = self.eventsViewController.weekEvent?.key
            completion(
                weeks.map { week in
                    UIAction(title: week.weekString, state: week.key == currentKey ? .on : .off) {
                        [weak self] _ in
                        self?.eventsViewController.weekEvent = week
                    }
                }
            )
        }
    }

}

extension EventsContainerViewController: WeekEventsDelegate {

    func weekEventUpdated() {
        updateInterface()
    }

}

extension EventsContainerViewController: SearchContainerDelegate,
    SearchViewControllerDelegate
{}

// MARK: - EventsListViewControllerDelegate

extension EventsContainerViewController: EventsListViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, dependencies: dependencies)
        navigationController?.pushViewController(eventViewController, animated: true)
    }
}
