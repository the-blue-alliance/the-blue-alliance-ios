import CoreData
import UIKit

class EventViewController: MyTBAContainerViewController {

    private(set) var event: Event
    private let userDefaults: UserDefaults

    override var subscribableModel: MyTBASubscribable {
        return event
    }

    // MARK: - Init

    init(event: Event, myTBA: MyTBA, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.event = event
        self.userDefaults = userDefaults

        let infoViewController = EventInfoViewController(event: event, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit)
        let teamsViewController = TeamsViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit)
        let rankingsViewController = EventRankingsViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit)
        let matchesViewController = MatchesViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit)

        super.init(viewControllers: [infoViewController, teamsViewController, rankingsViewController, matchesViewController],
                   segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],
                   myTBA: myTBA,
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit)

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

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)
    }

}

extension EventViewController: EventInfoViewControllerDelegate {

    func showAlliances() {
        let eventAlliancesViewController = EventAlliancesContainerViewController(event: event, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(eventAlliancesViewController, animated: true)
    }

    func showAwards() {
        let eventAwardsViewController = EventAwardsContainerViewController(event: event, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(eventAwardsViewController, animated: true)
    }

    func showDistrictPoints() {
        let eventDistrictPointsViewController = EventDistrictPointsContainerViewController(event: event, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(eventDistrictPointsViewController, animated: true)
    }

    func showStats() {
        let eventStatsContainerViewController = EventStatsContainerViewController(event: event, myTBA: myTBA, userDefaults: userDefaults, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(eventStatsContainerViewController, animated: true)
    }

}

extension EventViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: team.teamKey, event: event, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: EventRankingsViewControllerDelegate {

    func rankingSelected(_ ranking: EventRanking) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: ranking.teamKey!, event: event, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: MatchesViewControllerDelegate {

    func matchSelected(_ match: Match) {
        let matchViewController = MatchContainerViewController(match: match, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}
