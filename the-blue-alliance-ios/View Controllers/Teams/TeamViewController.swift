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
    var year: Int? {
        didSet {
            // TODO: Pass year down to VCs that need it
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    
    internal var infoViewController: TeamInfoTableViewController!
    @IBOutlet internal var infoView: UIView?
    
    @IBOutlet internal var eventsView: UIView?
    @IBOutlet internal var mediaView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Team \(team.teamNumber)"
        
        viewControllers = [infoViewController]
        containerViews = [infoView!]
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        
        updateInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshYearsParticipated()
    }
    
    // MARK: - Private
    
    func updateInterface() {
        navigationTitleLabel?.text = "Team \(team.teamNumber)"
        
        if !team.yearsParticipated.isEmpty, let year = year {
            navigationDetailLabel?.text = "▾ \(year)"
        } else {
            navigationDetailLabel?.text = "▾ ----"
        }
    }
    
    func refreshYearsParticipated() {
        _ = TBATeam.fetchYearsParticipated(team.key!) { (years, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to fetch years participated - \(error.localizedDescription)")
                return
            }
            
            guard let years = years as? [Int] else {
                return
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                self.team.yearsParticipated = years
                try? backgroundContext.save()
                
                if self.year == nil, !self.team.yearsParticipated.isEmpty {
                    self.year = self.team.yearsParticipated.first
                }
            })
        }
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
        }
    }
    
}
