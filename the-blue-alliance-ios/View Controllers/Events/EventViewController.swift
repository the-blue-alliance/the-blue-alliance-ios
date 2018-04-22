//
//  EventViewController.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/7/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit

class EventViewController: ContainerViewController {

    public var event: Event!
    
    internal var infoViewController: EventInfoTableViewController!
    @IBOutlet internal var infoView: UIView!
    
    internal var teamsViewController: TeamsTableViewController!
    @IBOutlet internal var teamsView: UIView!
    
    internal var rankingsViewController: EventRankingsTableViewController!
    @IBOutlet internal var rankingsView: UIView!
    
    internal var matchesViewController: MatchesTableViewController!
    @IBOutlet internal var matchesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = event.friendlyNameWithYear
        
        viewControllers = [infoViewController, teamsViewController, rankingsViewController, matchesViewController]
        containerViews = [infoView, teamsView, rankingsView, matchesView]
        
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
    }
        
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventInfoEmbed" {
            infoViewController = segue.destination as! EventInfoTableViewController
            infoViewController.event = event
            infoViewController.showAwards = {
                self.performSegue(withIdentifier: "EventAwardsSegue", sender: nil)
            }
            infoViewController.showDistrictPoints = {
                self.performSegue(withIdentifier: "EventPointsSegue", sender: nil)
            }
            infoViewController.showStats = {
                self.performSegue(withIdentifier: "EventStatsSegue", sender: nil)
            }
        } else if segue.identifier == "EventTeamsEmbed" {
            teamsViewController = segue.destination as! TeamsTableViewController
            teamsViewController.event = event
            teamsViewController.teamSelected = { team in
                self.performSegue(withIdentifier: "TeamAtEventSegue", sender: team);
            }
        } else if segue.identifier == "EventMatchesEmbed" {
            matchesViewController = segue.destination as! MatchesTableViewController
            matchesViewController.event = event
            matchesViewController.matchSelected = { match in
                self.performSegue(withIdentifier: "MatchSegue", sender: match)
            }
        } else if segue.identifier == "EventRankingsEmbed" {
           rankingsViewController = segue.destination as! EventRankingsTableViewController
            rankingsViewController.event = event
            rankingsViewController.rankingSelected = { team in
                // TODO: Show team@event
            }
        } else if segue.identifier == "EventAwardsSegue" {
            let eventAwardsViewController = segue.destination as! EventAwardsViewController
            eventAwardsViewController.event = event
            eventAwardsViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "EventPointsSegue" {
            let eventAwardsViewController = segue.destination as! EventDistrictPointsViewController
            eventAwardsViewController.event = event
            eventAwardsViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "MatchSegue" {
            let match = sender as! Match
            let matchViewController = segue.destination as! MatchViewController
            matchViewController.match = match
            matchViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "EventStatsSegue" {
            let statsViewController = segue.destination as! EventStatsContainerViewController
            statsViewController.event = event
            statsViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "TeamAtEventSegue" {
            let team = sender as! Team
            let teamAtEventViewController = segue.destination as! TeamAtEventViewController
            teamAtEventViewController.team = team
            teamAtEventViewController.event = event
            teamAtEventViewController.persistentContainer = persistentContainer
        }
    }

}
