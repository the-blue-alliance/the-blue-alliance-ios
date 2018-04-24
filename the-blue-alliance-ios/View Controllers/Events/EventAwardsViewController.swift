//
//  EventAwardsTableViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/17/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit
import CoreData
import TBAKit

class EventAwardsViewController: ContainerViewController {
    
    public var event: Event!
    
    internal var awardsViewController: EventAwardsTableViewController!
    @IBOutlet internal var awardsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitleLabel?.text = "Awards"
        navigationDetailLabel?.text = "@ \(event.friendlyNameWithYear)"
        
        viewControllers = [awardsViewController]
        containerViews = [awardsView]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventAwardsEmbed" {
            awardsViewController = segue.destination as! EventAwardsTableViewController
            awardsViewController.event = event
            awardsViewController.persistentContainer = persistentContainer
            awardsViewController.teamSelected = { [weak self] team in
                self?.performSegue(withIdentifier: "TeamAtEventSegue", sender: team)
            }
        } else if segue.identifier == "TeamAtEventSegue" {
            let team = sender as! Team
            let teamAtEventViewController = segue.destination as! TeamAtEventViewController
            teamAtEventViewController.team = team
            teamAtEventViewController.event = event
            teamAtEventViewController.persistentContainer = persistentContainer
        }
    }

}

class EventAwardsTableViewController: TBATableViewController {

    var event: Event!
    var team: Team?

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    var teamSelected: ((Team) -> ())?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: AwardTableViewCell.self), bundle: nil), forCellReuseIdentifier: AwardTableViewCell.reuseIdentifier)
    }
        
    // MARK: - Refreshing
    
    override func refresh() {
        removeNoDataView()
       
        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventAwards(key: event.key!, completion: { (awards, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event awards - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                
                let localAwards = awards?.map({ (modelAward) -> Award in
                    return Award.insert(with: modelAward, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.awards = Set(localAwards ?? []) as NSSet
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event awards - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }
    
    override func shouldNoDataRefresh() -> Bool {
        if let awards = dataSource?.fetchedResultsController.fetchedObjects, awards.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: Table View Data Source
    
    fileprivate var dataSource: TableViewDataSource<Award, EventAwardsTableViewController>?
    
    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<Award> = Award.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "awardType", ascending: true)]
        
        setupFetchRequest(fetchRequest)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: AwardTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }
    
    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }
    
    fileprivate func setupFetchRequest(_ request: NSFetchRequest<Award>) {
        if let team = team {
            request.predicate = NSPredicate(format: "event == %@ AND (ANY recipients.team == %@)", event, team)
        } else {
            request.predicate = NSPredicate(format: "event == %@", event)
        }
    }
    
}

extension EventAwardsTableViewController: TableViewDataSourceDelegate {
    
    func configure(_ cell: AwardTableViewCell, for object: Award, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.award = object
        cell.teamSelected = teamSelected
    }
    
    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: String(format: "No awards for %@", team != nil ? "team at event" : "event"))
    }
    
    func hideNoDataView() {
        removeNoDataView()
    }
    
}
