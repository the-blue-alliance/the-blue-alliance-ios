import CoreData
import UIKit

class EventViewController: ContainerViewController {

    private let event: Event
    private let userDefaults: UserDefaults

    // MARK: - Init

    init(event: Event, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.userDefaults = userDefaults

        let infoViewController = EventInfoViewController(event: event, urlOpener: urlOpener, persistentContainer: persistentContainer)
        let teamsViewController = TeamsViewController(event: event, persistentContainer: persistentContainer)
        let rankingsViewController = EventRankingsViewController(event: event, persistentContainer: persistentContainer)
        let matchesViewController = MatchesViewController(event: event, persistentContainer: persistentContainer)

        super.init(viewControllers: [infoViewController, teamsViewController, rankingsViewController, matchesViewController],
                   segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],
                   persistentContainer: persistentContainer)

        infoViewController.delegate = self
        teamsViewController.delegate = self
        rankingsViewController.delegate = self
        matchesViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = event.friendlyNameWithYear

        // TODO: Document what this is, and see if we can move it... literally anywhere else
        // Because, for what it's worth, I'm *pretty sure* this shouldn't be here, unless maybe iPad?
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
    }

}

extension EventViewController: EventInfoViewControllerDelegate {

    func showAlliances() {
        let eventAlliancesViewController = EventAlliancesContainerViewController(event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventAlliancesViewController, animated: true)
    }

    func showAwards() {
        let eventAwardsViewController = EventAwardsContainerViewController(event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventAwardsViewController, animated: true)
    }

    func showDistrictPoints() {
        let eventDistrictPointsViewController = EventDistrictPointsContainerViewController(event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventDistrictPointsViewController, animated: true)
    }

    func showStats() {
        let eventStatsContainerViewController = EventStatsContainerViewController(event: event, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventStatsContainerViewController, animated: true)
    }

}

extension EventViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: team.teamKey, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: EventRankingsViewControllerDelegate {

    func rankingSelected(_ ranking: EventRanking) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: ranking.teamKey!, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: MatchesViewControllerDelegate {

    func matchSelected(_ match: Match) {
        let matchViewController = MatchContainerViewController(match: match, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}
