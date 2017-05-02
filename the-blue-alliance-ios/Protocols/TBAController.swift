//
//  TBAController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/18/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol TBAContainerController {
    var viewControllers: [TBAPersistenceController] { get set }
    var containerViews: [UIView] { get set }

    var segmentedControl: UISegmentedControl? { get set }
}

extension TBAContainerController {
    
    func updateSegmentedControlViews() {
        if segmentedControl == nil && containerViews.count == 1 {
            show(view: containerViews.first!)
        } else if let segmentedControl = segmentedControl, containerViews.count > segmentedControl.selectedSegmentIndex {
            show(view: containerViews[segmentedControl.selectedSegmentIndex])
        }
    }
    
    private func show(view showView: UIView) {
        for (_, containerView) in containerViews.enumerated() {
            let shouldHide = !(containerView == showView)
            // TODO: Eventually, make sure we call refresh for new VC
            containerView.isHidden = shouldHide
        }
    }
    
}

protocol TBAPersistenceController {
    var persistentContainer: NSPersistentContainer! { get set }
}

class TBAViewController: UIViewController, TBAContainerController, TBAPersistenceController {
    
    var persistentContainer: NSPersistentContainer!

    var viewControllers: [TBAPersistenceController] = [] {
        didSet {
            if let persistentContainer = persistentContainer {
                for controller in viewControllers {
                    var c = controller
                    c.persistentContainer = persistentContainer
                }
            }
        }
    }
    var containerViews: [UIView] = []
    
    @IBOutlet var navigationTitleLabel: UILabel? {
        didSet {
            navigationTitleLabel?.textColor = UIColor.white
        }
    }
    @IBOutlet var navigationDetailLabel: UILabel? {
        didSet {
            navigationDetailLabel?.textColor = UIColor.white
        }
    }
    
    @IBOutlet var segmentedControl: UISegmentedControl?
    @IBOutlet var segmentedControlView: UIView? {
        didSet {
            segmentedControlView?.backgroundColor = UIColor.primaryBlue
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSegmentedControlViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // cancelRefreshes()
    }
    
    @IBAction func segmentedControlValueChanged(sender: Any) {
        // cancelRefreshes()
        updateSegmentedControlViews()
    }
    
}

class TBATableViewController: UITableViewController, TBAPersistenceController {
    
    var persistentContainer: NSPersistentContainer!
    var noDataViewController: NoDataViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.backgroundColor = UIColor.color(red: 239, green: 239, blue: 239)
        tableView.tableFooterView = UIView.init(frame: .zero)
    }
    
    func showNoData(withText text: String?) {
        if noDataViewController == nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            noDataViewController = mainStoryboard.instantiateViewController(withIdentifier: "NoDataViewController") as? NoDataViewController
        }
        
        if let text = text {
            noDataViewController?.textLabel?.text = text
        } else {
            noDataViewController?.textLabel?.text = "No data to display"
        }
        
        if noDataViewController?.view.superview == nil {
            noDataViewController?.view.alpha = 0.0
            tableView.backgroundView = noDataViewController?.view
            
            weak var weakSelf = self
            UIView.animate(withDuration: 0.25, animations: {
                weakSelf!.noDataViewController?.view.alpha = 1.0
            })
        }
    }
    
    func hideNoData() {
        if noDataViewController != nil {
            tableView.backgroundView = nil
        }
    }
    
}
