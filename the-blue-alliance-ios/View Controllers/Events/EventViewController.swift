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
    @IBOutlet internal var infoView: UIView?
    
    internal var teamsViewController: TeamsTableViewController!
    @IBOutlet internal var teamsView: UIView?
    
    @IBOutlet internal var rankingsView: UIView?
    @IBOutlet internal var matchesView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = event.friendlyNameWithYear
        
        viewControllers = [infoViewController, teamsViewController]
        containerViews = [infoView!, teamsView!]
        
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
        } else if segue.identifier == "EventTeamsEmbed" {
            teamsViewController = segue.destination as! TeamsTableViewController
            teamsViewController.event = event
            teamsViewController.teamSelected = { team in
                // TOOD: Show team@event
            }
        }
    }

}
