//
//  TeamViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/12/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAKit

class TeamViewController: ContainerViewController {
    
    public var team: Team!
    var currentYear: Int?
    
    // internal var infoViewController: EventInfoTableViewController!
    // @IBOutlet internal var infoView: UIView?
    
    @IBOutlet internal var teamsView: UIView?
    @IBOutlet internal var rankingsView: UIView?
    @IBOutlet internal var matchesView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Team \(team.teamNumber)"
        
        // viewControllers = [infoViewController]
        // containerViews = [infoView!]
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    // MARK: - Private
    
    func refreshYearsParticipated() {
        TBATea
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
}
