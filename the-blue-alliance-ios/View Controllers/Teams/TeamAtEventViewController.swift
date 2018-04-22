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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Setup Segues here
        if segue.identifier == "TeamAtEventStatusEmbed" {
            summaryViewController = segue.destination as! TeamSummaryTableViewController
        } else if segue.identifier == "TeamAtEventMatchesEmbed" {
            matchesViewController = segue.destination as! MatchesTableViewController
            matchesViewController.event = event
            matchesViewController.team = team
            matchesViewController.matchSelected = { match in
                self.performSegue(withIdentifier: "MatchSegue", sender: match)
            }
        } else if segue.identifier == "TeamAtEventStatsEmbed" {
            statsViewController = segue.destination as! TeamStatsTableViewController
        } else if segue.identifier == "TeamAtEventAwardsEmbed" {
            awardsViewController = segue.destination as! EventAwardsTableViewController
            awardsViewController.event = event
            awardsViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "MatchSegue" {
            let match = sender as! Match
            let matchViewController = segue.destination as! MatchViewController
            matchViewController.match = match
            matchViewController.team = team
            matchViewController.persistentContainer = persistentContainer
        }
    }
    
}
