import MyTBAKit
import Photos
import TBAAPI
import UIKit

class EventViewController: MyTBAContainerViewController, EventStatusSubscribable {

    private let eventKey: String
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private(set) var statusService: StatusService
    private(set) var urlOpener: URLOpener

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

    init(eventKey: String, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, myTBA: MyTBA, myTBAStores: MyTBAStores, dependencies: Dependencies) {
        self.eventKey = eventKey
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        infoViewController = EventInfoViewController(eventKey: eventKey, urlOpener: urlOpener, dependencies: dependencies)
        teamsViewController = EventTeamsViewController(eventKey: eventKey, dependencies: dependencies)
        rankingsViewController = EventRankingsViewController(eventKey: eventKey, dependencies: dependencies)
        matchesViewController = MatchesViewController(eventKey: eventKey, myTBA: myTBA, favoritesStore: myTBAStores.favorites, dependencies: dependencies)

        super.init(viewControllers: [infoViewController, teamsViewController, rankingsViewController, matchesViewController],
                   navigationTitle: eventKey,
                   segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],
                   myTBA: myTBA,
                   myTBAStores: myTBAStores,
                   dependencies: dependencies)

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
        let eventAlliancesViewController = EventAlliancesContainerViewController(event: event, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(eventAlliancesViewController, animated: true)
    }

    func showAwards() {
        guard let event else { return }
        let eventAwardsViewController = EventAwardsContainerViewController(event: event, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(eventAwardsViewController, animated: true)
    }

    func showDistrictPoints() {
        guard let event else { return }
        let eventDistrictPointsViewController = EventDistrictPointsContainerViewController(event: event, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(eventDistrictPointsViewController, animated: true)
    }

    func showInsights() {
        guard let event else { return }
        let eventInsightsContainerViewController = EventInsightsContainerViewController(event: event, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(eventInsightsContainerViewController, animated: true)
    }

}

extension EventViewController: TeamsListViewControllerDelegate {

    func teamSelected(teamKey: String) {
        pushTeamAtEvent(teamKey: teamKey)
    }

}

extension EventViewController: EventRankingsViewControllerDelegate {

    func rankingSelected(_ ranking: EventRanking.RankingsPayloadPayload) {
        pushTeamAtEvent(teamKey: ranking.teamKey)
    }

    private func pushTeamAtEvent(teamKey: String) {
        let year = event?.year ?? Int(eventKey.prefix(4)) ?? 0
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: eventKey, year: year, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable {

    func matchSelected(matchKey: String) {
        let matchViewController = MatchViewController(matchKey: matchKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, myTBAStores: myTBAStores, dependencies: dependencies)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}
