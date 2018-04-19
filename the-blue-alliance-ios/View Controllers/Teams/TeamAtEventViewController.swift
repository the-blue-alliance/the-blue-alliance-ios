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
        
        // viewControllers = [summaryViewController, matchesViewController, statsViewController, awardsViewController]
        // containerViews = [statusView, matchesView, statsView, awardsView]
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Setup Segues here
    }
    
}
