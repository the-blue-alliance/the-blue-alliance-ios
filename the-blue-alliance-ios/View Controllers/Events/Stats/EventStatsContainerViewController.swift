import CoreData
import TBAKit
import UIKit

class EventStatsContainerViewController: ContainerViewController {
    public var event: Event!

    internal var teamStatsViewController: EventTeamStatsTableViewController!
    @IBOutlet internal var teamStatsView: UIView!

    internal var eventStatsViewController: EventStatsViewController!
    @IBOutlet internal var eventStatsView: UIView!

    @IBOutlet internal var filerBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel?.text = "Stats"
        navigationDetailLabel?.text = "@ \(event.friendlyNameWithYear)"

        // Only show event stats if year is 2016 or onward
        if Int(event.year) >= 2016 {
            viewControllers = [teamStatsViewController, eventStatsViewController]
            containerViews = [teamStatsView, eventStatsView]
        } else {
            segmentedControlView?.isHidden = true
            eventStatsView.isHidden = true

            viewControllers = [teamStatsViewController]
            containerViews = [teamStatsView]
        }
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TeamStatsEmbed" {
            teamStatsViewController = segue.destination as! EventTeamStatsTableViewController
            teamStatsViewController.event = event
            teamStatsViewController.persistentContainer = persistentContainer
            teamStatsViewController.teamSelected = { [weak self] team in
                self?.performSegue(withIdentifier: "TeamAtEventSegue", sender: team)
            }
        } else if segue.identifier == "EventStatsEmbed" {
            eventStatsViewController = segue.destination as! EventStatsViewController
            eventStatsViewController.event = event
            eventStatsViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "SelectFilterSegue" {
            let nav = segue.destination as! UINavigationController
            let selectTableViewController = SelectTableViewController<Int>()
            selectTableViewController.title = "Sort stats by"
            selectTableViewController.current = teamStatsViewController.filter.rawValue
            selectTableViewController.compareCurrent = { current, option in
                return current == option
            }
            selectTableViewController.options = Array(EventTeamStatFilter.opr.rawValue..<EventTeamStatFilter.max.rawValue)
            selectTableViewController.optionSelected = { [weak self] filter in
                guard let filterType = EventTeamStatFilter(rawValue: filter) else {
                    fatalError("Invalid filter")
                }
                self?.teamStatsViewController.filter = filterType
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
            nav.viewControllers = [selectTableViewController]
        } else if segue.identifier == "TeamAtEventSegue" {
            let team = sender as! Team
            let teamAtEventViewController = segue.destination as! TeamAtEventViewController
            teamAtEventViewController.team = team
            teamAtEventViewController.event = event
            teamAtEventViewController.persistentContainer = persistentContainer
        }
    }
}
