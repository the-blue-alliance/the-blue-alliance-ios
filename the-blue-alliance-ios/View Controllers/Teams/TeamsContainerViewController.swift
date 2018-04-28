import Foundation
import UIKit
import CoreData
import TBAKit

let TeamsEmbed = "TeamsEmbed"
let TeamSegue = "TeamSegue"

class TeamsContainerViewController: ContainerViewController {
    internal var teamsViewController: TeamsTableViewController!
    @IBOutlet internal var teamsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        viewControllers = [teamsViewController]
        containerViews = [teamsView]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TeamSegue {
            let teamViewController = (segue.destination as! UINavigationController).topViewController as! TeamViewController
            teamViewController.team = sender as? Team
            // TODO: Find a way to pass these down automagically like we did in the Obj-C version
            teamViewController.persistentContainer = persistentContainer
        } else if segue.identifier == TeamsEmbed {
            teamsViewController = segue.destination as? TeamsTableViewController
            teamsViewController?.teamSelected = { [weak self] team in
                self?.performSegue(withIdentifier: TeamSegue, sender: team)
            }
        }
    }
    
}
