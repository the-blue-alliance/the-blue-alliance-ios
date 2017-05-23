//
//  EventViewController.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/7/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit
import React

class EventViewController: ContainerViewController {

    public var event: Event!
    
    internal var infoViewController: EventInfoTableViewController!
    @IBOutlet internal var infoView: UIView!
    
    internal var teamsViewController: TeamsTableViewController!
    @IBOutlet internal var teamsView: UIView!
    
    @IBOutlet internal var rankingsView: UIView?
    
    internal var matchesViewController: MatchesTableViewController!
    @IBOutlet internal var matchesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = event.friendlyNameWithYear
        
        viewControllers = [infoViewController, teamsViewController, matchesViewController]
        containerViews = [infoView, teamsView, matchesView]
        
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
        } else if segue.identifier == "EventTeamsEmbed" {
            teamsViewController = segue.destination as! TeamsTableViewController
            teamsViewController.event = event
            teamsViewController.teamSelected = { team in
                // TOOD: Show team@event
                let jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: "")
                let rootVC = RCTRootView(bundleURL: jsCodeLocation!, moduleName: "TBATeamAtEventStatus", initialProperties: [:], launchOptions: [:])
                let viewController = UIViewController()
                viewController.view = rootVC
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        } else if segue.identifier == "EventMatchesEmbed" {
            matchesViewController = segue.destination as! MatchesTableViewController
            matchesViewController.event = event
            matchesViewController.matchSelected = { match in
                self.performSegue(withIdentifier: "MatchSegue", sender: match)
            }
        } else if segue.identifier == "EventAwardsSegue" {
            let eventAwardsViewController = segue.destination as! EventAwardsViewController
            eventAwardsViewController.event = event
            eventAwardsViewController.persistentContainer = persistentContainer
        } else if segue.identifier == "MatchSegue" {
            let match = sender as! Match
            let matchViewController = segue.destination as! MatchViewController
            matchViewController.match = match
            matchViewController.persistentContainer = persistentContainer
        }
    }

}
