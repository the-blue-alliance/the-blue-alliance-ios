import Firebase
import Foundation
import CoreData
import UIKit

class TeamAtEventViewController: ContainerViewController {

    private let teamKey: TeamKey
    private let event: Event

    // Where should we push to, when clicking the navigation bar from the top. Should be the opposite of what view sent us here
    // Ex: A EventStats VC is contexted as an Event view controller, so showDetailTeam should be true
    private let showDetailEvent: Bool
    private let showDetailTeam: Bool

    private let statusService: StatusService
    private let urlOpener: URLOpener
    private let myTBA: MyTBA

    private var teamRequest: URLSessionDataTask?


    // MARK: - Init

    init(teamKey: TeamKey, event: Event, myTBA: MyTBA, showDetailEvent: Bool, showDetailTeam: Bool, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.teamKey = teamKey
        self.event = event
        self.showDetailEvent = showDetailEvent
        self.showDetailTeam = showDetailTeam
        self.statusService = statusService
        self.urlOpener = urlOpener
        self.myTBA = myTBA

        let summaryViewController: TeamSummaryViewController = TeamSummaryViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let matchesViewController: MatchesViewController = MatchesViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let statsViewController: TeamStatsViewController = TeamStatsViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let awardsViewController: EventAwardsViewController = EventAwardsViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [summaryViewController, matchesViewController, statsViewController, awardsViewController],
                   navigationTitle: "Team \(teamKey.teamNumber)",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   segmentedControlTitles: ["Summary", "Matches", "Stats", "Awards"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        if showDetailEvent {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.eventIcon, style: .plain, target: self, action: #selector(pushEvent))
        } else if showDetailTeam {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.teamIcon, style: .plain, target: self, action: #selector(pushTeam))
        }

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

        teamRequest?.cancel()
    }

    // MARK: - Private Methods

    @objc private func pushEvent() {
        let eventViewController = EventViewController(event: event, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    @objc private func pushTeam() {
        _pushTeam(attemptedToLoadTeam: false)
    }
    
    private func _pushTeam(attemptedToLoadTeam: Bool) {
        guard let team = teamKey.team else {
            if attemptedToLoadTeam {
                showErrorAlert(with: "Unable to load team.")
            } else {
                let oldRightBarButtonIcon = navigationItem.rightBarButtonItem
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem.activityIndicatorBarButtonItem()
                }

                teamRequest = tbaKit.fetchTeam(key: teamKey.key!, completion: { (team, error) in
                    let context = self.persistentContainer.newBackgroundContext()
                    context.performChangesAndWait({
                        if let team = team {
                            Team.insert(team, in: context)
                        }
                    }, saved: {
                        // Switch back to our main thread
                        DispatchQueue.main.async {
                            self._pushTeam(attemptedToLoadTeam: true) // Try again - but don't get in to a cycle if the request is failing
                        }
                    })

                    self.teamRequest = nil

                    // Reset our nav bar item
                    DispatchQueue.main.async {
                        self.navigationItem.rightBarButtonItem = oldRightBarButtonIcon
                    }
                })
            }
            return
        }

        _pushTeam(team: team)
    }

    private func _pushTeam(team: Team) {
        let eventViewController = TeamViewController(team: team, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, TeamSummaryViewControllerDelegate {

    func awardsSelected() {
        // TODO: Suspect....
        let awardsViewController = EventAwardsContainerViewController(event: event, teamKey: teamKey, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(awardsViewController, animated: true)
    }

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, teamKey: teamKey, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamKeySelected(_ teamKey: TeamKey) {
        // Don't push to team@event for team we're already showing team@event for
        if self.teamKey == teamKey {
            return
        }

        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, event: event, myTBA: myTBA, showDetailEvent: showDetailEvent, showDetailTeam: showDetailTeam, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
