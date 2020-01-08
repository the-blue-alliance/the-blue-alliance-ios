import CoreData
import Firebase
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class EventViewController: MyTBAContainerViewController, EventStatusSubscribable {

    private(set) var event: Event
    private(set) var statusService: StatusService
    private(set) var urlOpener: URLOpener

    private(set) var infoViewController: EventInfoViewController
    private(set) var teamsViewController: EventTeamsViewController
    private(set) var rankingsViewController: EventRankingsViewController
    private(set) var matchesViewController: MatchesViewController

    override var subscribableModel: MyTBASubscribable {
        return event
    }

    // MARK: - Init

    init(event: Event, statusService: StatusService, urlOpener: URLOpener, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.event = event
        self.statusService = statusService
        self.urlOpener = urlOpener

        infoViewController = EventInfoViewController(event: event, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        teamsViewController = EventTeamsViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        rankingsViewController = EventRankingsViewController(event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        matchesViewController = MatchesViewController(event: event, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [infoViewController, teamsViewController, rankingsViewController, matchesViewController],
                   segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],
                   myTBA: myTBA,
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        // TODO: We'll absolutely need to update this title
        title = event.friendlyNameWithYear

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

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)

        if isEventDown(eventKey: event.key) {
            showOfflineEventMessage(shouldShow: true, animated: false)
        }
        registerForEventStatusChanges(eventKey: event.key)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("event", parameters: ["event": event.key])
    }

    // MARK: - Interface Methods

    func eventStatusChanged(isEventOffline: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.showOfflineEventMessage(shouldShow: isEventOffline)
        }
    }

}

extension EventViewController: EventInfoViewControllerDelegate {

    func showAlliances() {
        let eventAlliancesViewController = EventAlliancesContainerViewController(event: event, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(eventAlliancesViewController, animated: true)
    }

    func showAwards() {
        let eventAwardsViewController = EventAwardsContainerViewController(event: event, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(eventAwardsViewController, animated: true)
    }

    func showDistrictPoints() {
        let eventDistrictPointsViewController = EventDistrictPointsContainerViewController(event: event, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(eventDistrictPointsViewController, animated: true)
    }

    func showStats() {
        let eventStatsContainerViewController = EventStatsContainerViewController(event: event, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(eventStatsContainerViewController, animated: true)
    }

}

extension EventViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: EventRankingsViewControllerDelegate {

    func rankingSelected(_ ranking: EventRanking) {
        let teamAtEventViewController = TeamAtEventViewController(team: ranking.team, event: event, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable {

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}
