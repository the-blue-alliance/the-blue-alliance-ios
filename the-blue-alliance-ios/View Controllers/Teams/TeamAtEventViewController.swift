//
//  TeamAtEventViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/4/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

class TeamAtEventViewController: ContainerViewController {
    
    public var team: Team!
    public var event: Event!
    
    internal var summaryViewController: TeamSummaryTableViewController!
    @IBOutlet internal var statusView: UIView!
    
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
        containerViews = [statusView, matchesView, statsView, awardsView]
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SelectYearSegue, team.yearsParticipated.isEmpty {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue {
            let nav = segue.destination as! UINavigationController
            let selectTableViewController = SelectTableViewController<Int>()
            selectTableViewController.title = "Select Year"
            selectTableViewController.current = year
            selectTableViewController.options = team.yearsParticipated
            selectTableViewController.optionSelected = { year in
                self.year = year
            }
            selectTableViewController.optionString = { year in
                return String(year)
            }
            nav.viewControllers = [selectTableViewController]
        } else if segue.identifier == "TeamInfoEmbed" {
            infoViewController = segue.destination as? TeamInfoTableViewController
            infoViewController.team = team
        } else if segue.identifier == "TeamEventsEmbed" {
            statsViewController = segue.destination as? EventTeamStatsTableViewController
            
            
            
            eventsViewController = segue.destination as? EventsTableViewController
            eventsViewController.team = team
            eventsViewController.year = year
        } else if segue.identifier == "TeamAwardEmbed" {
            awardsViewController = segue.destination as? EventAwardsTableViewController
            awardsViewController.event = event
            awardsViewController.team = team
        }
    }
    
}

}
