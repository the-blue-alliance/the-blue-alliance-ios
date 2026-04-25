import MyTBAKit
import Photos
import TBAAPI
import UIKit

enum EventState {
    case key(String)
    case event(Event)

    var key: String {
        switch self {
        case .key(let key): return key
        case .event(let event): return event.key
        }
    }

    var event: Event? {
        switch self {
        case .key: return nil
        case .event(let event): return event
        }
    }
}

class EventViewController: MyTBAContainerViewController, EventStatusSubscribable {

    private var state: EventState

    private(set) var infoViewController: EventInfoViewController
    private(set) var teamsViewController: EventTeamsViewController
    private(set) var rankingsViewController: EventRankingsViewController
    private(set) var matchesViewController: MatchesViewController

    override var subscribableModel: MyTBASubscribable {
        EventSubscribable(modelKey: state.key)
    }

    // MARK: - Init

    convenience init(eventKey: String, name: String? = nil, dependencies: Dependencies) {
        self.init(state: .key(eventKey), eventName: name, dependencies: dependencies)
    }

    convenience init(event: Event, dependencies: Dependencies) {
        self.init(state: .event(event), eventName: nil, dependencies: dependencies)
    }

    private init(state: EventState, eventName: String?, dependencies: Dependencies) {
        self.state = state

        switch state {
        case .key(let eventKey):
            infoViewController = EventInfoViewController(
                eventKey: eventKey,
                name: eventName,
                dependencies: dependencies
            )
        case .event(let event):
            infoViewController = EventInfoViewController(event: event, dependencies: dependencies)
        }
        teamsViewController = EventTeamsViewController(
            eventKey: state.key,
            dependencies: dependencies
        )
        rankingsViewController = EventRankingsViewController(
            eventKey: state.key,
            dependencies: dependencies
        )
        if let event = state.event {
            matchesViewController = MatchesViewController(
                event: event,
                dependencies: dependencies
            )
        } else {
            matchesViewController = MatchesViewController(
                eventKey: state.key,
                dependencies: dependencies
            )
        }

        let navTitle = state.event?.friendlyNameWithYear ?? state.key
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

        if isEventDown(eventKey: state.key) {
            showOfflineEventMessage(shouldShow: true, animated: false)
        }
        registerForEventStatusChanges(eventKey: state.key)

        Task { @MainActor in
            if let fetched = try? await api.event(key: state.key) {
                state = .event(fetched)
                title = fetched.friendlyNameWithYear
                navigationTitle = fetched.friendlyNameWithYear
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Event: \(state.key)")
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
        guard let event = state.event else { return }
        let eventAlliancesViewController = EventAlliancesContainerViewController(
            event: event,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(eventAlliancesViewController, animated: true)
    }

    func showAwards() {
        guard let event = state.event else { return }
        let eventAwardsViewController = EventAwardsContainerViewController(
            event: event,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(eventAwardsViewController, animated: true)
    }

    func showDistrictPoints() {
        guard let event = state.event else { return }
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
        guard let event = state.event else { return }
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
        let year = state.event?.year ?? Int(state.key.prefix(4)) ?? 0
        let teamAtEventViewController = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: state.key,
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
