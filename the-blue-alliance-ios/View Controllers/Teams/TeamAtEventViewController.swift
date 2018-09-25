import Foundation
import CoreData
import UIKit

class TeamAtEventViewController: ContainerViewController {

    private let team: Team
    private let event: Event

    private var summaryViewController: TeamSummaryViewController!
    private var matchesViewController: MatchesViewController!
    private var statsViewController: TeamStatsViewController!
    private var awardsViewController: EventAwardsViewController!

    override var viewControllers: [Refreshable & Stateful] {
        return [summaryViewController, matchesViewController, statsViewController, awardsViewController]
    }

    // MARK: - Init

    init(team: Team, event: Event, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.event = event

        super.init(segmentedControlTitles: ["Summary", "Matches", "Stats", "Awards"],
                   persistentContainer: persistentContainer)

        summaryViewController = TeamSummaryViewController(team: team, event: event, delegate: self, persistentContainer: persistentContainer)
        matchesViewController = MatchesViewController(event: event, team: team, delegate: self, persistentContainer: persistentContainer)
        statsViewController = TeamStatsViewController(team: team, event: event, persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitle = "Team \(team.teamNumber)"
        navigationSubtitle = "@ \(event.friendlyNameWithYear)"
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, TeamSummaryViewControllerDelegate {

    func awardsSelected() {
        let awardsViewController = EventAwardsContainerViewController(event: event, team: team, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(awardsViewController, animated: true)
    }

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, team: team, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        // Don't push to team@event for team we're already showing team@event for
        if self.team == team {
            return
        }

        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
