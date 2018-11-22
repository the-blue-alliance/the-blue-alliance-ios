import Foundation
import CoreData
import UIKit

class TeamAtEventViewController: ContainerViewController {

    private let teamKey: TeamKey
    private let event: Event

    // MARK: - Init

    init(teamKey: TeamKey, event: Event, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.teamKey = teamKey
        self.event = event

        let summaryViewController: TeamSummaryViewController = TeamSummaryViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let matchesViewController: MatchesViewController = MatchesViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let statsViewController: TeamStatsViewController = TeamStatsViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let awardsViewController: EventAwardsViewController = EventAwardsViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [summaryViewController, matchesViewController, statsViewController, awardsViewController],
                   segmentedControlTitles: ["Summary", "Matches", "Stats", "Awards"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        navigationTitle = "Team \(teamKey.teamNumber)"
        navigationSubtitle = "@ \(event.friendlyNameWithYear)"

        summaryViewController.delegate = self
        matchesViewController.delegate = self
        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, TeamSummaryViewControllerDelegate {

    func awardsSelected() {
        let awardsViewController = EventAwardsContainerViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(awardsViewController, animated: true)
    }

    func matchSelected(_ match: Match) {
        let matchViewController = MatchContainerViewController(match: match, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamKeySelected(_ teamKey: TeamKey) {
        // Don't push to team@event for team we're already showing team@event for
        if self.teamKey == teamKey {
            return
        }

        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
