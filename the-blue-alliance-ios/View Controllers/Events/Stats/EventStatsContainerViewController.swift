import Foundation
import CoreData
import TBAKit
import UIKit

class EventStatsContainerViewController: ContainerViewController {

    private let event: Event

    private let teamStatsViewController: EventTeamStatsTableViewController

    lazy private var filerBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "ic_sort_white"),
                               style: .plain,
                               target: self,
                               action: #selector(showFilter))
    }()

    // MARK: - Init

    init(event: Event, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.event = event

        teamStatsViewController = EventTeamStatsTableViewController(event: event, userDefaults: userDefaults, persistentContainer: persistentContainer)

        var eventStatsViewController: EventStatsViewController?
        // Only show event stats if year is 2016 or onward
        var titles = ["Team Stats"]
        if Int(event.year) >= 2016 {
            titles.append("Event Stats")
            eventStatsViewController = EventStatsViewController(event: event, persistentContainer: persistentContainer)
        }

        super.init(viewControllers: [teamStatsViewController, eventStatsViewController].compactMap({ $0 }),
                   segmentedControlTitles: titles,
                   persistentContainer: persistentContainer)

        teamStatsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitle = "Stats"
        navigationSubtitle = "@ \(event.friendlyNameWithYear)"
    }

    // MARK: - Interface Actions

    @objc private func showFilter() {
        let selectTableViewController = SelectTableViewController<EventStatsContainerViewController>(current: teamStatsViewController.filter, options: EventTeamStatFilter.allCases, persistentContainer: persistentContainer)
        selectTableViewController.title = "Sort stats by"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFilter))

        navigationController?.present(nav, animated: true, completion: nil)
    }

    @objc private func dismissFilter() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Container

    override func switchedToIndex(_ index: Int) {
        // Show filter button if we switched to the team stats view controller
        // Otherwise, hide the filter button
        if index == 0 {
            navigationItem.rightBarButtonItem = filerBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = nil
        }
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

    func eventTeamStatSelected(_ eventTeamStat: EventTeamStat) {
        let teamAtEventViewController = TeamAtEventViewController(team: eventTeamStat.team!, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
