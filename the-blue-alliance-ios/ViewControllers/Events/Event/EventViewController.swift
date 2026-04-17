import MyTBAKit
import Photos
import TBAAPI
import UIKit

class EventViewController: MyTBAContainerViewController, EventStatusSubscribable {

    private let eventKey: String

    // Loaded from TBAAPI after init; used for nav title + for the event struct
    // passed to the detail container VCs (alliances/awards/etc.).
    private var event: Event?

    private(set) var infoViewController: EventInfoViewController
    private(set) var teamsViewController: EventTeamsViewController
    private(set) var rankingsViewController: EventRankingsViewController
    private(set) var matchesViewController: MatchesViewController

    override var subscribableModel: MyTBASubscribable {
        EventSubscribable(modelKey: eventKey)
    }

    // MARK: - Init

    // Key-only: nothing known about the event yet.
    init(eventKey: String, dependencies: Dependencies) {
        self.eventKey = eventKey

        infoViewController = EventInfoViewController(eventKey: eventKey, dependencies: dependencies)
        teamsViewController = EventTeamsViewController(eventKey: eventKey, dependencies: dependencies)
        rankingsViewController = EventRankingsViewController(eventKey: eventKey, dependencies: dependencies)
        matchesViewController = MatchesViewController(eventKey: eventKey, dependencies: dependencies)

        // Raw key ("2026miket") is ugly; "2026" prefix is the best guess until the event loads.
        let initialTitle = Self.yearPrefixedTitle(eventKey: eventKey, name: nil) ?? eventKey
        super.init(viewControllers: [infoViewController, teamsViewController, rankingsViewController, matchesViewController],
                   navigationTitle: initialTitle,
                   segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],


                   dependencies: dependencies)

        infoViewController.delegate = self
        teamsViewController.delegate = self
        rankingsViewController.delegate = self
        matchesViewController.delegate = self
    }

    // Partial data (e.g. key + name from search).
    convenience init(eventKey: String, name: String?, dependencies: Dependencies) {
        self.init(eventKey: eventKey, dependencies: dependencies)
        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedName, !trimmedName.isEmpty {
            navigationTitle = Self.yearPrefixedTitle(eventKey: eventKey, name: trimmedName)
            infoViewController.applyPartial(name: trimmedName)
        }
    }

    // Full event from a list view: seed info now, still refresh in viewDidLoad.
    convenience init(event: Event, dependencies: Dependencies) {
        self.init(eventKey: event.key, dependencies: dependencies)
        self.event = event
        title = event.friendlyNameWithYear
        navigationTitle = event.friendlyNameWithYear
        infoViewController.apply(event: event)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func yearPrefixedTitle(eventKey: String, name: String?) -> String? {
        let year = String(eventKey.prefix(4))
        guard year.allSatisfy(\.isNumber) else { return name }
        if let name, !name.isEmpty {
            return "\(year) \(name)"
        }
        return year
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
        [.upcomingMatch, .matchScore, .levelStarting, .allianceSelection, .awards, .scheduleUpdated, .finalResults]
    }
}

extension EventViewController: EventInfoViewControllerDelegate {

    func showAlliances() {
        guard let event else { return }
        let eventAlliancesViewController = EventAlliancesContainerViewController(event: event, dependencies: dependencies)
        self.navigationController?.pushViewController(eventAlliancesViewController, animated: true)
    }

    func showAwards() {
        guard let event else { return }
        let eventAwardsViewController = EventAwardsContainerViewController(event: event, dependencies: dependencies)
        self.navigationController?.pushViewController(eventAwardsViewController, animated: true)
    }

    func showDistrictPoints() {
        guard let event else { return }
        let eventDistrictPointsViewController = EventDistrictPointsContainerViewController(event: event, dependencies: dependencies)
        self.navigationController?.pushViewController(eventDistrictPointsViewController, animated: true)
    }

    func showInsights() {
        guard let event else { return }
        let eventInsightsContainerViewController = EventInsightsContainerViewController(event: event, dependencies: dependencies)
        self.navigationController?.pushViewController(eventInsightsContainerViewController, animated: true)
    }

}

extension EventViewController: TeamsListViewControllerDelegate {

    func teamSelected(_ team: Team) {
        pushTeamAtEvent(teamKey: team.key)
    }

}

extension EventViewController: EventRankingsViewControllerDelegate {

    func rankingSelected(_ ranking: EventRanking.RankingsPayloadPayload) {
        pushTeamAtEvent(teamKey: ranking.teamKey)
    }

    private func pushTeamAtEvent(teamKey: String) {
        let year = event?.year ?? Int(eventKey.prefix(4)) ?? 0
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: eventKey, year: year, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable {

    func matchSelected(matchKey: String) {
        let matchViewController = MatchViewController(matchKey: matchKey, dependencies: dependencies)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}
