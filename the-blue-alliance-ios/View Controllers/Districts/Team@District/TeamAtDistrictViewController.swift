import Foundation
import UIKit

class TeamAtDistrictViewController: ContainerViewController {
    
    public var ranking: DistrictRanking!
    
    internal var summaryViewController: DistrictTeamSummaryTableViewController!
    @IBOutlet internal var summaryView: UIView!
    
    internal var breakdownViewController: DistrictBreakdownTableViewController!
    @IBOutlet internal var breakdownView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitleLabel?.text = "Team \(ranking.team!.teamNumber)"
        navigationDetailLabel?.text = "@ \(ranking.district!.abbreviationWithYear)"
        
        viewControllers = [summaryViewController, breakdownViewController]
        containerViews = [summaryView, breakdownView]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DistrictTeamSummaryEmbed" {
            summaryViewController = segue.destination as! DistrictTeamSummaryTableViewController
            summaryViewController.ranking = ranking
            summaryViewController.eventPointsSelected = { [weak self] eventPoints in
                self?.performSegue(withIdentifier: "TeamAtEventSegue", sender: eventPoints)
            }
        } else if segue.identifier == "DistrictBreakdownEmbed" {
            breakdownViewController = segue.destination as! DistrictBreakdownTableViewController
            breakdownViewController.ranking = ranking
        } else if segue.identifier == "TeamAtEventSegue" {
            let eventPoints = sender as! DistrictEventPoints
            let teamAtEventViewController = segue.destination as! TeamAtEventViewController
            teamAtEventViewController.team = eventPoints.team!
            teamAtEventViewController.event = eventPoints.event!
            teamAtEventViewController.persistentContainer = persistentContainer
        }
    }
    
}
