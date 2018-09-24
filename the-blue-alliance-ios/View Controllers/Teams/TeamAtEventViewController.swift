import Foundation
import CoreData
import UIKit

class TeamAtEventViewController: ContainerViewController {

    var team: Team
    var event: Event

    init(team: Team, event: Event, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.event = event

        super.init(segmentedControlTitles: ["Summary", "Matches", "Stats", "Awards"],
                   persistentContainer: persistentContainer)

        let summaryViewController = TeamSummaryTableViewController(team: team, event: event, awardsSelected: { [unowned self] in
            let awardsViewController = EventAwardsViewController(event: event, team: team, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(awardsViewController, animated: true)
            }, matchSelected: { (match) in
                let matchViewController = MatchViewController(match: match, team: team, persistentContainer: persistentContainer)
                self.navigationController?.pushViewController(matchViewController, animated: true)
        }, persistentContainer: persistentContainer)

        let matchesViewController = MatchesTableViewController(event: event, team: team, matchSelected: { (match) in
            let matchViewController = MatchViewController(match: match, team: team, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(matchViewController, animated: true)
        }, persistentContainer: persistentContainer)

        let statsViewController = TeamStatsTableViewController(persistentContainer: persistentContainer, team: team, event: event)

        let awardsViewController = EventAwardsTableViewController(event: event, team: team, teamSelected: { [unowned self] (team) in
            // Don't push to team@event for team we're already showing team@event for
            if self.team == team {
                return
            }

            let teamAtEventViewController = TeamAtEventViewController(team: team, event: self.event, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
            }, persistentContainer: persistentContainer)

        viewControllers = [summaryViewController, matchesViewController, statsViewController, awardsViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel.text = "Team \(team.teamNumber)"
        navigationDetailLabel.text = "@ \(event.friendlyNameWithYear)"
    }

}
