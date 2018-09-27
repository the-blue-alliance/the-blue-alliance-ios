import CoreData
import UIKit

class EventViewController: ContainerViewController {

    private let event: Event
    private let userDefaults: UserDefaults

    private var infoViewController: EventInfoViewController!
    private var teamsViewController: TeamsViewController!
    private var rankingsViewController: EventRankingsViewController!
    private var matchesViewController: MatchesViewController!

    override var viewControllers: [ContainableViewController] {
        return [infoViewController, teamsViewController, rankingsViewController, matchesViewController]
    }

    // MARK: - Init

    init(event: Event, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.event = event
        self.userDefaults = userDefaults

        super.init(segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],
                   persistentContainer: persistentContainer)

        infoViewController = EventInfoViewController(event: event, delegate: self, urlOpener: urlOpener, persistentContainer: persistentContainer)
        teamsViewController = TeamsViewController(delegate: self, event: event, persistentContainer: persistentContainer)
        rankingsViewController = EventRankingsViewController(event: event, delegate: self, persistentContainer: persistentContainer)
        matchesViewController = MatchesViewController(event: event, delegate: self, persistentContainer: persistentContainer)
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
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: EventRankingsViewControllerDelegate {

    func rankingSelected(_ ranking: EventRanking) {
        let teamAtEventViewController = TeamAtEventViewController(team: ranking.team!, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: MatchesViewControllerDelegate {

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}
