//
//  TeamsContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/12/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TBAKit

let TeamsEmbed = "TeamsEmbed"
let TeamSegue = "TeamSegue"

class TeamsContainerViewController: ContainerViewController {
    internal var teamsViewController: TeamsTableViewController?
    @IBOutlet internal var teamsView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [teamsViewController!]
        containerViews = [teamsView!]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TeamSegue {
            /*
            let eventViewController = (segue.destination as! UINavigationController).topViewController as! EventViewController
            eventViewController.event = sender as? Event
            // TODO: Find a way to pass these down automagically like we did in the Obj-C version
            eventViewController.persistentContainer = persistentContainer
            */
        } else if segue.identifier == TeamsEmbed {
            teamsViewController = segue.destination as? TeamsTableViewController
            teamsViewController?.teamSelected = { team in
                self.performSegue(withIdentifier: TeamSegue, sender: team)
            }
        }
    }
    
}
