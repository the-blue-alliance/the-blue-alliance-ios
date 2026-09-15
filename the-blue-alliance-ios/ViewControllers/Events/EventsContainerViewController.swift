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

        rightBarButtonItems = [UIBarButtonItem(pill: yearButton)]
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
        setNeedsUpdateProperties()
    }

    private lazy var yearButton = UIButton.menuPill(title: String(year), menu: yearMenu())

    // Reading `maxSeason` here rebuilds the menu when `/status` loads after the first week does.
    override func updateProperties() {
        super.updateProperties()

        yearButton.menu = yearMenu()
    }

    // Years as submenus, each loading its weeks when opened, the way the old modal did in
    // two screens. A submenu can't be checked, so the selected year shows its week as a subtitle.
    private func yearMenu() -> UIMenu {
        let selectedWeek = eventsViewController.weekEvent
        return UIMenu(
            children: Array(1992...statusService.maxSeason).reversed().map { year in
                UIMenu(
                    title: String(year),
                    subtitle: year == selectedWeek?.year ? selectedWeek?.weekString : nil,
                    children: [
                        UIDeferredMenuElement.uncached { [weak self] completion in
                            self?.loadWeekActions(for: year, completion: completion)
                        }
                    ]
                )
            }
        )
    }

    private func loadWeekActions(for year: Int, completion: @escaping ([UIMenuElement]) -> Void) {
        Task { [weak self] in
            guard let self else { return }
            let events = (try? await self.dependencies.api.eventsByYear(year)) ?? []
            let weeks = WeekEventsGrouping.weekEvents(for: year, from: events)
            guard !weeks.isEmpty else {
                completion([UIAction(title: "No weeks", attributes: .disabled) { _ in }])
                return
            }
            let currentWeek = self.eventsViewController.weekEvent
            completion(
                weeks.map { week in
                    let isCurrent =
                        currentWeek.map { WeekEventsGrouping.isSameWeek(week, $0) } ?? false
                    return UIAction(title: week.weekString, state: isCurrent ? .on : .off) {
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

// MARK: - EventsListViewControllerDelegate

extension EventsContainerViewController: EventsListViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, dependencies: dependencies)
        navigationController?.pushViewController(eventViewController, animated: true)
    }
}
