import Foundation
import CoreData
import TBAKit
import UIKit

class EventStatsContainerViewController: ContainerViewController {

    typealias OptionType = EventTeamStatFilter

    private let event: Event

    private var teamStatsViewController: EventTeamStatsTableViewController!
    private var eventStatsViewController: EventStatsViewController?

    override var viewControllers: [ContainableViewController] {
        return [teamStatsViewController, eventStatsViewController].compactMap({ $0 })
    }

    lazy private var filerBarButtonItem: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(image: UIImage(named: "ic_sort_white"),
                               style: .plain,
                               target: self,
                               action: #selector(showFilter))
    }()

    // MARK: - Init

    init(event: Event, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.event = event

        // Only show event stats if year is 2016 or onward
        var titles = ["Team Stats"]
        if Int(event.year) >= 2016 {
            titles.append("Event Stats")
        }

        super.init(segmentedControlTitles: titles,
                   persistentContainer: persistentContainer)

        eventStatsViewController = EventStatsViewController(event: event, persistentContainer: persistentContainer)
        teamStatsViewController = EventTeamStatsTableViewController(event: event, delegate: self, userDefaults: userDefaults, persistentContainer: persistentContainer)
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
        let selectViewController = SelectViewController<EventStatsContainerViewController>(current: teamStatsViewController.filter, options: EventTeamStatFilter.allCases)
        selectViewController.title = "Sort stats by"
        selectViewController.selectTableViewControllerDelegate = self
        navigationController?.present(selectViewController, animated: true, completion: nil)
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
