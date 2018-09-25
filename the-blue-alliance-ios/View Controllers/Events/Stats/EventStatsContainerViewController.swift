import Foundation
import CoreData
import TBAKit
import UIKit

class EventStatsContainerViewController: ContainerViewController {

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

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        // Only show event stats if year is 2016 or onward
        var titles = ["Team Stats"]
        if Int(event.year) >= 2016 {
            titles.append("Event Stats")
        }

        super.init(segmentedControlTitles: titles,
                   persistentContainer: persistentContainer)

        eventStatsViewController = EventStatsViewController(event: event, persistentContainer: persistentContainer)
        teamStatsViewController = EventTeamStatsTableViewController(event: event, delegate: self, persistentContainer: persistentContainer)
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

extension EventStatsContainerViewController: EventTeamStatsSelectionDelegate {

    func eventTeamStatSelected(_ eventTeamStat: EventTeamStat) {
        let teamAtEventViewController = TeamAtEventViewController(team: eventTeamStat.team!, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
