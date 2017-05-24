//
//  MatchViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

class MatchViewController: ContainerViewController {

    public var match: Match!
    public var team: Team?
    
    internal var matchInfoViewController: MatchInfoViewController!
    @IBOutlet internal var infoView: UIView!
    
    internal var matchBreakdownViewController: MatchBreakdownViewController!
    @IBOutlet internal var breakdownView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitleLabel?.text = "\(match.friendlyMatchName())"
        navigationDetailLabel?.text = "@ \(match.event!.friendlyNameWithYear)"
        
        viewControllers = [matchInfoViewController, matchBreakdownViewController]
        containerViews = [infoView, breakdownView]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MatchInfoEmbed" {
            matchInfoViewController = segue.destination as! MatchInfoViewController
            matchInfoViewController.match = match
            matchInfoViewController.team = team
        } else if segue.identifier == "MatchBreakdownEmbed" {
            matchBreakdownViewController = segue.destination as! MatchBreakdownViewController
            matchBreakdownViewController.match = match
        }
    }

}


