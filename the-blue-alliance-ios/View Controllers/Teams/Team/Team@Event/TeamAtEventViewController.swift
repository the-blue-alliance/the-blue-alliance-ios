import CoreData
import Firebase
import Foundation
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class TeamAtEventViewController: ContainerViewController, ContainerTeamPushable {

    let team: Team

    let event: Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    let myTBA: MyTBA
    let statusService: StatusService
    let urlOpener: URLOpener
    var matchesViewController: MatchesViewController

    // MARK: - Init

    init(team: Team, event: Event, myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.team = team
        self.event = event
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        let summaryViewController = TeamSummaryViewController(team: team, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        matchesViewController = MatchesViewController(event: event, team: team, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let statsViewController = TeamStatsViewController(team: team, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let awardsViewController = EventAwardsViewController(event: event, team: team, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [summaryViewController, matchesViewController, statsViewController, awardsViewController],
                   navigationTitle: team.teamNumberNickname,
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   segmentedControlTitles: ["Summary", "Matches", "Stats", "Awards"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        rightBarButtonItems = [
            UIBarButtonItem(image: UIImage.eventIcon, style: .plain, target: self, action: #selector(pushEvent)),
            UIBarButtonItem(image: UIImage.teamIcon, style: .plain, target: self, action: #selector(pushTeam))
        ]

        summaryViewController.delegate = self
        matchesViewController.delegate = self
        awardsViewController.delegate = self

        contextObserver.observeObject(object: event, state: .updated) { [weak self] (event, _) in
            guard let self = self else { return }
            self.navigationSubtitle = "@ \(event.friendlyNameWithYear)"
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("team_at_event", parameters: ["event": event.key, "team": team.key])
    }

    // MARK: - Private Methods

    @objc private func pushEvent() {
        let eventViewController = EventViewController(event: event, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    @objc private func pushTeam() {
        pushTeam(team: team)
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable, TeamSummaryViewControllerDelegate {

    func awardsSelected() {
        let awardsViewController = EventAwardsContainerViewController(event: event, team: team, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(awardsViewController, animated: true)
    }

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, team: team, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        // Don't push to team@event for team we're already showing team@event for
        if self.team == team {
            return
        }

        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
