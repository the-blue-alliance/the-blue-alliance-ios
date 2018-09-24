import Foundation
import CoreData
import TBAKit
import UIKit

class EventStatsContainerViewController: ContainerViewController {

    let event: Event

    private var teamStatsViewController: EventTeamStatsTableViewController?

    private let filerBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "ic_sort_white"),
                               style: .plain,
                               target: self,
                               action: #selector(showFilter))
    }()

    // MARK: - Init

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(segmentedControlTitles: ["Team Stats", "Event Stats"],
                   persistentContainer: persistentContainer)

        teamStatsViewController = EventTeamStatsTableViewController(event: event, teamSelected: { [unowned self] (team) in
            let teamAtEventViewController = TeamAtEventViewController(team: team, event: self.event, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
            }, persistentContainer: persistentContainer)

        var viewControllers: [Persistable & Refreshable & Stateful] = [teamStatsViewController!]

        // Only show event stats if year is 2016 or onward
        if Int(event.year) >= 2016 {
            let eventStatsViewController = EventStatsViewController(event: event, persistentContainer: persistentContainer)
            viewControllers.append(eventStatsViewController)
        }

        self.viewControllers = viewControllers
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel.text = "Stats"
        navigationDetailLabel.text = "@ \(event.friendlyNameWithYear)"
    }

    // MARK: - Interface Actions

    @objc private func showFilter() {
        let selectTableViewController = SelectTableViewController<Int>()
        selectTableViewController.title = "Sort stats by"
        selectTableViewController.current = teamStatsViewController!.filter.rawValue
        selectTableViewController.compareCurrent = { current, option in
            return current == option
        }
        selectTableViewController.options = Array(EventTeamStatFilter.opr.rawValue..<EventTeamStatFilter.max.rawValue)
        selectTableViewController.optionSelected = { [unowned self] filter in
            guard let filterType = EventTeamStatFilter(rawValue: filter) else {
                fatalError("Invalid filter")
            }
            self.teamStatsViewController!.filter = filterType
        }
        selectTableViewController.optionString = { filter in
            switch filter {
            case EventTeamStatFilter.opr.rawValue:
                return "OPR"
            case EventTeamStatFilter.dpr.rawValue:
                return "DPR"
            case EventTeamStatFilter.ccwm.rawValue:
                return "CCWM"
            case EventTeamStatFilter.teamNumber.rawValue:
                return "Team #"
            default:
                return ""
            }
        }

        let navigationController = UINavigationController(rootViewController: selectTableViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
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
