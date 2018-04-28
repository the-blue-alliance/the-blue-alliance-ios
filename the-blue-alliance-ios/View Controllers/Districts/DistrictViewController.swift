//
//  DistrictViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/13/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

class DistrictViewController: ContainerViewController {

    public var district: District!
    
    internal var eventsViewController: EventsTableViewController!
    @IBOutlet internal var eventsView: UIView!
    
    internal var rankingsViewController: DistrictRankingsTableViewController!
    @IBOutlet internal var rankingsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(district.year) \(district.name!) Districts"
        
        viewControllers = [eventsViewController, rankingsViewController]
        containerViews = [eventsView, rankingsView]
        
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DistrictEventsEmbed" {
            eventsViewController = segue.destination as! EventsTableViewController
            eventsViewController.district = district
            eventsViewController.eventSelected = { [weak self] event in
                self?.performSegue(withIdentifier: EventSegue, sender: event)
            }
        } else if segue.identifier == "DistrictRankingsEmbed" {
            rankingsViewController = segue.destination as! DistrictRankingsTableViewController
            rankingsViewController.district = district
            rankingsViewController.rankingSelected = { ranking in
                // TODO: Show team @ district VC
            }
        } else if segue.identifier == EventSegue {
            let eventViewController = segue.destination as! EventViewController
            eventViewController.event = sender as? Event
            // TODO: Find a way to pass these down automagically like we did in the Obj-C version
            eventViewController.persistentContainer = persistentContainer
        }
    }

}
