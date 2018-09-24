import CoreData
import UIKit

class EventViewController: ContainerViewController {

    let event: Event

    init(event: Event, persistentContainer: NSPersistentContainer) {
        self.event = event

        super.init(segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],
                   persistentContainer: persistentContainer)

        let infoViewController = EventInfoTableViewController(event: event, persistentContainer: persistentContainer)
        let teamsViewController = TeamsTableViewController(teamSelected: pushToTeamAtEvent, persistentContainer: persistentContainer)
        let rankingsViewController = EventRankingsTableViewController(event: event, rankingSelected: { [unowned self] (ranking) in
            self.pushToTeamAtEvent(team: ranking.team!)
            }, persistentContainer: persistentContainer)
        let matchesViewController = MatchesTableViewController(event: event, matchSelected: { [unowned self] (match) in
            let matchViewController = MatchViewController(match: match, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(matchViewController, animated: true)
            }, persistentContainer: persistentContainer)

        viewControllers = [infoViewController, teamsViewController, rankingsViewController, matchesViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func pushToTeamAtEvent(team: Team) {
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = event.friendlyNameWithYear

        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
    }

}
