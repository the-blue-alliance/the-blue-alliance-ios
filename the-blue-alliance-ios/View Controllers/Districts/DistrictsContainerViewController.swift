//
//  DistrictsContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/13/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import TBAKit

class DistrictsContainerViewController: ContainerViewController {
    
    var maxYear: Int?
    var year: Int? {
        didSet {
            if let districtsViewController = districtsViewController {
                districtsViewController.year = year
            }
            
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    
    internal var districtsViewController: DistrictsTableViewController!
    @IBOutlet internal var districtsView: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let year = UserDefaults.standard.integer(forKey: StatusConstants.currentSeasonKey)
        if year != 0 {
            self.year = year
        }
        
        let maxYear = UserDefaults.standard.integer(forKey: StatusConstants.maxSeasonKey)
        if maxYear != 0 {
            self.maxYear = maxYear
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.fetchedTBAStatus),
                                               name: Notification.Name(kFetchedTBAStatus),
                                               object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [districtsViewController]
        containerViews = [districtsView!]
        
        updateInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if year == nil {
            
        }
    }
    
    // MARK: - Private Methods
    
    func updateInterface() {
        navigationTitleLabel?.text = "Districts"
        
        if let year = year {
            navigationDetailLabel?.text = "▾ \(year)"
        } else {
            navigationDetailLabel?.text = "▾ ----"
        }
    }

    // MARK: - Observers
    
    func fetchedTBAStatus(notification: NSNotification) {
        guard let status = notification.object as? TBAStatus else {
            showErrorAlert(with: "TBA status fetch failed")
            return
        }
        if year == nil {
            year = Int(status.currentSeason)
        }
        maxYear = Int(status.maxSeason)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SelectYearSegue, maxYear == nil, year == nil {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue {
            let nav = segue.destination as! UINavigationController
            let selectTableViewController = SelectTableViewController<Int>()
            selectTableViewController.title = "Select Year"
            selectTableViewController.current = year!
            selectTableViewController.options = Array(2009...maxYear!).reversed()
            selectTableViewController.optionSelected = { year in
                self.year = year
            }
            selectTableViewController.optionString = { year in
                return String(year)
            }
            nav.viewControllers = [selectTableViewController]
        } else if segue.identifier == "DistrictsEmbed" {
            districtsViewController = segue.destination as? DistrictsTableViewController
            districtsViewController.year = year
            districtsViewController.districtSelected = { district in
                // TODO: Show districts view controller
            }
        }
    }
}
