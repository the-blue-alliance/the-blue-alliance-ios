import CoreData
import Firebase
import Foundation
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class TeamAtEventViewController: ContainerViewController, ContainerTeamPushable {

    let teamKey: TeamKey
    private let event: Event

    // Where should we push to, when clicking the navigation bar from the top. Should be the opposite of what view sent us here
    // Ex: A EventStats VC is contexted as an Event view controller, so showDetailTeam should be true
    private let showDetailEvent: Bool
    private let showDetailTeam: Bool

    var pushTeamBarButtonItem: UIBarButtonItem?

    let messaging: Messaging
    let myTBA: MyTBA
    let statusService: StatusService
    let urlOpener: URLOpener

    // MARK:  - ContainerTeamPushable

    var fetchTeamOperationQueue: OperationQueue = OperationQueue()

    // MARK: - Init

    init(teamKey: TeamKey, event: Event, messaging: Messaging, myTBA: MyTBA, showDetailEvent: Bool, showDetailTeam: Bool, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.teamKey = teamKey
        self.event = event
        self.showDetailEvent = showDetailEvent
        self.showDetailTeam = showDetailTeam
        self.myTBA = myTBA
        self.messaging = messaging
        self.statusService = statusService
        self.urlOpener = urlOpener

        let summaryViewController = TeamSummaryViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let matchesViewController = MatchesViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let statsViewController = TeamStatsViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let awardsViewController = EventAwardsViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [summaryViewController, matchesViewController, statsViewController, awardsViewController],
                   navigationTitle: "Team \(teamKey.teamNumber)",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   segmentedControlTitles: ["Summary", "Matches", "Stats", "Awards"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        pushTeamBarButtonItem = {
            if showDetailEvent {
                return UIBarButtonItem(image: UIImage.eventIcon, style: .plain, target: self, action: #selector(pushEvent))
            } else if showDetailTeam {
                return UIBarButtonItem(image: UIImage.teamIcon, style: .plain, target: self, action: #selector(pushTeam))
            } else {
                return nil
            }
        }()
        rightBarButtonItems = [pushTeamBarButtonItem].compactMap({ $0 })

        summaryViewController.delegate = self
        matchesViewController.delegate = self
        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("team_at_event", parameters: ["event": event.key!, "team": teamKey.key!])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: Move this out in to some shared class with TeamAtDistrict
        fetchTeamOperationQueue.cancelAllOperations()
    }

    // MARK: - Private Methods

    @objc private func pushEvent() {
        let eventViewController = EventViewController(event: event, statusService: statusService, urlOpener: urlOpener, messaging: messaging, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    @objc private func pushTeam() {
        _pushTeam(attemptedToLoadTeam: false)
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, TeamSummaryViewControllerDelegate {

    func awardsSelected() {
        let awardsViewController = EventAwardsContainerViewController(event: event, teamKey: teamKey, messaging: messaging, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(awardsViewController, animated: true)
    }

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, teamKey: teamKey, statusService: statusService, urlOpener: urlOpener, messaging: messaging, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamKeySelected(_ teamKey: TeamKey) {
        // Don't push to team@event for team we're already showing team@event for
        if self.teamKey == teamKey {
            return
        }

        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, event: event, messaging: messaging, myTBA: myTBA, showDetailEvent: showDetailEvent, showDetailTeam: showDetailTeam, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
