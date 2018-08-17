import Foundation
import UIKit

class TeamAtEventViewController: ContainerViewController {

    // TODO: Team@Event needs myTBA
    public var team: Team!
    public var event: Event!

    internal var summaryViewController: TeamSummaryTableViewController!
    @IBOutlet internal var summaryView: UIView!

    internal var matchesViewController: MatchesTableViewController!
    @IBOutlet internal var matchesView: UIView!

    internal var statsViewController: TeamStatsTableViewController!
    @IBOutlet internal var statsView: UIView!

    internal var awardsViewController: EventAwardsTableViewController!
    @IBOutlet internal var awardsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel?.text = "Team \(team.teamNumber)"
        navigationDetailLabel?.text = "@ \(event.friendlyNameWithYear)"

        viewControllers = [summaryViewController, matchesViewController, statsViewController, awardsViewController]
        containerViews = [summaryView, matchesView, statsView, awardsView]
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TeamAtEventSummaryEmbed" {
            summaryViewController = segue.destination as! TeamSummaryTableViewController
            summaryViewController.event = event
            summaryViewController.team = team
            summaryViewController.awardsSelected = { [weak self] in
                self?.performSegue(withIdentifier: "AwardsSegue", sender: nil)
            }
            summaryViewController.matchSelected = { [weak self] match in
                self?.performSegue(withIdentifier: "MatchSegue", sender: match)
            }
        } else if segue.identifier == "TeamAtEventMatchesEmbed" {
            matchesViewController = segue.destination as! MatchesTableViewController
            matchesViewController.event = event
            matchesViewController.team = team
            matchesViewController.matchSelected = { [weak self] match in
                self?.performSegue(withIdentifier: "MatchSegue", sender: match)
            }
        } else if segue.identifier == "TeamAtEventStatsEmbed" {
            statsViewController = segue.destination as! TeamStatsTableViewController
            statsViewController.event = event
            statsViewController.team = team
        } else if segue.identifier == "TeamAtEventAwardsEmbed" {
            awardsViewController = segue.destination as! EventAwardsTableViewController
            awardsViewController.event = event
            awardsViewController.team = team
            awardsViewController.teamSelected = { [weak self] team in
                // Don't push to team@event for team we're already showing team@event for
                guard let localTeam = self?.team, team != localTeam else {
                    return
                }
                self?.performSegue(withIdentifier: "TeamAtEventSegue", sender: team)
            }
        } else if segue.identifier == "MatchSegue" {
            let match = sender as! Match
            let matchViewController = segue.destination as! MatchViewController
            matchViewController.match = match
            matchViewController.team = team
            matchViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "AwardsSegue" {
            let awardsViewController = segue.destination as! EventAwardsViewController
            awardsViewController.event = event
            awardsViewController.team = team
            awardsViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "TeamAtEventSegue" {
            let team = sender as! Team
            let teamAtEventViewController = segue.destination as! TeamAtEventViewController
            teamAtEventViewController.team = team
            teamAtEventViewController.event = event
            teamAtEventViewController.persistentContainer = persistentContainer
        }
    }

}
