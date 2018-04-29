import Foundation
import UIKit

class TeamAtDistrictViewController: ContainerViewController {
    
    public var ranking: DistrictRanking!
    
    internal var summaryViewController: TeamSummaryTableViewController!
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
        if segue.identifier == "TeamAtDistrictSummaryEmbed" {
            summaryViewController = segue.destination as! TeamSummaryTableViewController
        } else if segue.identifier == "DistrictBreakdownEmbed" {
            breakdownViewController = segue.destination as! DistrictBreakdownTableViewController
            breakdownViewController.ranking = ranking
        }
    }
    
}
