import MyTBAKit
import Photos
import TBAAPI
import UIKit

class EventViewController: MyTBAContainerViewController, EventStatusSubscribable {

    private let eventKey: String
    private var event: Event?

    private(set) var infoViewController: EventInfoViewController
    private(set) var teamsViewController: EventTeamsViewController
    private(set) var rankingsViewController: EventRankingsViewController
    private(set) var matchesViewController: MatchesViewController

    override var subscribableModel: MyTBASubscribable {
        EventSubscribable(modelKey: eventKey)
    }

    // MARK: - Init

    convenience init(eventKey: String, name: String? = nil, dependencies: Dependencies) {
        self.init(eventKey: eventKey, event: nil, eventName: name, dependencies: dependencies)
    }

    convenience init(event: Event, dependencies: Dependencies) {
        self.init(eventKey: event.key, event: event, eventName: nil, dependencies: dependencies)
    }

    private init(eventKey: String, event: Event?, eventName: String?, dependencies: Dependencies) {
        self.eventKey = eventKey
        self.event = event

        if let event {
            infoViewController = EventInfoViewController(event: event, dependencies: dependencies)
        } else {
            infoViewController = EventInfoViewController(
                eventKey: eventKey,
                name: eventName,
                dependencies: dependencies
            )
        }
        teamsViewController = EventTeamsViewController(
            eventKey: eventKey,
            dependencies: dependencies
        )
        rankingsViewController = EventRankingsViewController(
            eventKey: eventKey,
            dependencies: dependencies
        )
        matchesViewController = MatchesViewController(
            eventKey: eventKey,
            dependencies: dependencies
        )

        let navTitle = event?.friendlyNameWithYear ?? eventKey
        super.init(
            viewControllers: [
                infoViewController, teamsViewController, rankingsViewController,
                matchesViewController,
            ],
            navigationTitle: navTitle,
            segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],
            dependencies: dependencies
        )

        title = navTitle

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

        if isEventDown(eventKey: eventKey) {
            showOfflineEventMessage(shouldShow: true, animated: false)
        }
        registerForEventStatusChanges(eventKey: eventKey)

        Task { @MainActor in
            if let fetched = try? await api.event(key: eventKey) {
                event = fetched
                title = fetched.friendlyNameWithYear
                navigationTitle = fetched.friendlyNameWithYear
            }
        }
    }

    // MARK: - Interface Methods

    func eventStatusChanged(isEventOffline: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.showOfflineEventMessage(shouldShow: isEventOffline)
        }
    }

}

private struct EventSubscribable: MyTBASubscribable {
    let modelKey: String
    var modelType: MyTBAModelType { .event }
    static var notificationTypes: [NotificationType] {
        [
            .upcomingMatch, .matchScore, .levelStarting, .allianceSelection, .awards,
            .scheduleUpdated, .finalResults,
        ]
    }
}

extension EventViewController: EventInfoViewControllerDelegate {

    func showAlliances() {
        guard let event else { return }
        let eventAlliancesViewController = EventAlliancesContainerViewController(
            event: event,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(eventAlliancesViewController, animated: true)
    }

    func showAwards() {
        guard let event else { return }
        let eventAwardsViewController = EventAwardsContainerViewController(
            event: event,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(eventAwardsViewController, animated: true)
    }

    func showDistrictPoints() {
        guard let event else { return }
        let eventDistrictPointsViewController = EventDistrictPointsContainerViewController(
            event: event,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(
            eventDistrictPointsViewController,
            animated: true
        )
    }

    func showInsights() {
        guard let event else { return }
        let eventInsightsContainerViewController = EventInsightsContainerViewController(
            event: event,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(
            eventInsightsContainerViewController,
            animated: true
        )
    }

}

extension EventViewController: TeamsListViewControllerDelegate {

    func teamSelected(_ team: any TeamDisplayable) {
        pushTeamAtEvent(teamKey: team.key)
    }

}

extension EventViewController: EventRankingsViewControllerDelegate {

    func rankingSelected(_ ranking: EventRanking.RankingsPayloadPayload) {
        pushTeamAtEvent(teamKey: ranking.teamKey)
    }

    private func pushTeamAtEvent(teamKey: String) {
        let year = event?.year ?? Int(eventKey.prefix(4)) ?? 0
        let teamAtEventViewController = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: eventKey,
            year: year,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable {

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(
            match: match,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}
