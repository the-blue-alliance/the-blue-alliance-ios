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
            eventsViewController.year = year
            mediaViewController.year = year
            
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    
    internal var infoViewController: TeamInfoTableViewController!
    @IBOutlet internal var infoView: UIView!
    
    internal var eventsViewController: EventsTableViewController!
    @IBOutlet internal var eventsView: UIView!

    internal var mediaViewController: TeamMediaCollectionViewController!
    @IBOutlet internal var mediaView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Team \(team.teamNumber)"
        
        viewControllers = [infoViewController, eventsViewController, mediaViewController]
        containerViews = [infoView, eventsView, mediaView]
        
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
        
        updateInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshYearsParticipated()
    }
    
    // MARK: - Private
    
    func updateInterface() {
        navigationTitleLabel?.text = "Team \(team.teamNumber)"
        
        
        if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty, let year = year {
            navigationDetailLabel?.text = "▾ \(year)"
        } else {
            navigationDetailLabel?.text = "▾ ----"
        }
    }
    
    func refreshYearsParticipated() {
        _ = TBAKit.sharedKit.fetchTeamYearsParticipated(key: team.key!, completion: { (years, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to fetch years participated - \(error.localizedDescription)")
                return
            }
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                if let years = years {
                    self.team.yearsParticipated = years.sorted().reversed()
                }
                try? backgroundContext.save()
                
                if self.year == nil, let yearsParticipated = self.team.yearsParticipated, !yearsParticipated.isEmpty {
                    self.year = yearsParticipated.first
                }
            })
        })
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SelectYearSegue {
            if let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty {
                return true
            }
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
        } else if segue.identifier == "TeamEventsEmbed" {
            eventsViewController = segue.destination as? EventsTableViewController
            eventsViewController.team = team
            eventsViewController.year = year
            eventsViewController.eventSelected = { event in
                self.performSegue(withIdentifier: "TeamAtEventSegue", sender: event)
            }
        } else if segue.identifier == "TeamMediaEmbed" {
            mediaViewController = segue.destination as? TeamMediaCollectionViewController
            mediaViewController.team = team
            mediaViewController.year = year
        } else if segue.identifier == "TeamAtEventSegue" {
            let event = sender as! Event
            let teamAtEventViewController = segue.destination as! TeamAtEventViewController
            teamAtEventViewController.team = team
            teamAtEventViewController.event = event
            teamAtEventViewController.persistentContainer = persistentContainer
        }
    }    
}
