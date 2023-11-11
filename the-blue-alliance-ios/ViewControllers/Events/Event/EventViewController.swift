import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class EventViewController: MyTBAContainerViewController, EventStatusSubscribable {

    private(set) var event: Event
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private(set) var statusService: StatusService
    private(set) var urlOpener: URLOpener

    private lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    private(set) var infoViewController: EventInfoViewController
    private(set) var teamsViewController: EventTeamsViewController
    private(set) var rankingsViewController: EventRankingsViewController
    private(set) var matchesViewController: MatchesViewController

    private var activity: NSUserActivity?

    override var subscribableModel: MyTBASubscribable {
        return event
    }

    // MARK: - Init

    init(event: Event, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, myTBA: MyTBA, dependencies: Dependencies) {
        self.event = event
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        infoViewController = EventInfoViewController(event: event, urlOpener: urlOpener, dependencies: dependencies)
        teamsViewController = EventTeamsViewController(event: event, dependencies: dependencies)
        rankingsViewController = EventRankingsViewController(event: event, dependencies: dependencies)
        matchesViewController = MatchesViewController(event: event, myTBA: myTBA, dependencies: dependencies)

        super.init(viewControllers: [infoViewController, teamsViewController, rankingsViewController, matchesViewController],
                   segmentedControlTitles: ["Info", "Teams", "Rankings", "Matches"],
                   myTBA: myTBA,
                   dependencies: dependencies)

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

        contextObserver.observeObject(object: event, state: .updated) { [weak self] (event, _) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.title = event.friendlyNameWithYear
            }
        }

        activity = event.userActivity
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Event: %@", [event.key])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        activity?.becomeCurrent()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        activity?.resignCurrent()
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
        let eventAlliancesViewController = EventAlliancesContainerViewController(event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(eventAlliancesViewController, animated: true)
    }

    func showAwards() {
        let eventAwardsViewController = EventAwardsContainerViewController(event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(eventAwardsViewController, animated: true)
    }

    func showDistrictPoints() {
        let eventDistrictPointsViewController = EventDistrictPointsContainerViewController(event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(eventDistrictPointsViewController, animated: true)
    }

    func showInsights() {
        let eventInsightsContainerViewController = EventInsightsContainerViewController(event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(eventInsightsContainerViewController, animated: true)
    }

}

extension EventViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: EventRankingsViewControllerDelegate {

    func rankingSelected(_ ranking: EventRanking) {
        let teamAtEventViewController = TeamAtEventViewController(team: ranking.team, event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension EventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable {

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}
