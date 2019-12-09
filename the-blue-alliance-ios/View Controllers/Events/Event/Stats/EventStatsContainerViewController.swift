import CoreData
import Firebase
import Foundation
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class EventStatsContainerViewController: ContainerViewController {

    private(set) var event: Event
    private let myTBA: MyTBA
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private let teamStatsViewController: EventTeamStatsTableViewController

    // MARK: - Init

    init(event: Event, myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        teamStatsViewController = EventTeamStatsTableViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        var eventStatsViewController: EventStatsViewController?
        // Only show event stats if year is 2016 or onward
        var titles = ["Team Stats"]
        if event.year!.intValue >= 2016 {
            titles.append("Event Stats")
            eventStatsViewController = EventStatsViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        }

        super.init(viewControllers: [teamStatsViewController, eventStatsViewController].compactMap({ $0 }),
                   navigationTitle: "Stats",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   segmentedControlTitles: titles,
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        teamStatsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("event_stats", parameters: ["event": event.key!])
    }

    // MARK: - Private Methods

    private func showFilter() {
        let selectTableViewController = SelectTableViewController<EventStatsContainerViewController>(current: teamStatsViewController.filter, options: EventTeamStatFilter.allCases, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        selectTableViewController.title = "Sort stats by"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFilter))

        navigationController?.present(nav, animated: true, completion: nil)
    }

    // MARK: - Interface Actions

    @objc private func dismissFilter() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}

extension EventStatsContainerViewController: SelectTableViewControllerDelegate {

    typealias OptionType = EventTeamStatFilter

    func optionSelected(_ option: OptionType) {
        teamStatsViewController.filter = option
    }

    func titleForOption(_ option: OptionType) -> String {
        return option.rawValue
    }

}

extension EventStatsContainerViewController: EventTeamStatsSelectionDelegate {

    func filterSelected() {
        showFilter()
    }

    func eventTeamStatSelected(_ eventTeamStat: EventTeamStat) {
        let teamAtEventViewController = TeamAtEventViewController(team: eventTeamStat.team!, event: event, myTBA: myTBA, showDetailEvent: false, showDetailTeam: true, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
