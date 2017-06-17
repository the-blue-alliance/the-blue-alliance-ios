//
//  EventPointsTableViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/4/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit
import CoreData
import TBAKit

class EventDistrictPointsViewController: ContainerViewController {
    public var event: Event!
    
    internal var districtPointsViewController: EventDistrictPointsTableViewController!
    @IBOutlet internal var districtPointsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitleLabel?.text = "District Points"
        navigationDetailLabel?.text = "@ \(event.friendlyNameWithYear)"
        
        viewControllers = [districtPointsViewController]
        containerViews = [districtPointsView]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventPointsEmbed" {
            districtPointsViewController = segue.destination as! EventDistrictPointsTableViewController
            districtPointsViewController.event = event
            districtPointsViewController.persistentContainer = persistentContainer
            districtPointsViewController.teamSelected = { team in
                // TODO: show team@event
            }
        }
    }
}

class EventDistrictPointsTableViewController: TBATableViewController {
    
    var event: Event!
    
    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    var teamSelected: ((Team) -> ())?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: RankingTableViewCell.self), bundle: nil), forCellReuseIdentifier: RankingTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    }
    
    // MARK: - Refreshing
    
    override func refresh() {
        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEventDistrictPoints(key: event.key!, completion: { (eventPoints, tiebreakers, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event district points - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                
                let localPoints = eventPoints?.map({ (modelPoints) -> EventPoints in
                    return EventPoints.insert(with: modelPoints, for: backgroundEvent, in: backgroundContext)
                })
                backgroundEvent.points = Set(localPoints ?? []) as NSSet
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event district points - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }
    
    override func shouldNoDataRefresh() -> Bool {
        if let points = dataSource?.fetchedResultsController.fetchedObjects, points.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: Table View Data Source
    
    fileprivate var dataSource: TableViewDataSource<EventPoints, EventDistrictPointsTableViewController>?
    
    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<EventPoints> = EventPoints.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "total", ascending: false)]
        
        setupFetchRequest(fetchRequest)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: RankingTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }
    
    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }
    
    fileprivate func setupFetchRequest(_ request: NSFetchRequest<EventPoints>) {
        request.predicate = NSPredicate(format: "event == %@", event)
    }
    
}

extension EventDistrictPointsTableViewController: TableViewDataSourceDelegate {
    
    func configure(_ cell: RankingTableViewCell, for object: EventPoints, at indexPath: IndexPath) {
        cell.points = object
        cell.rankLabel?.text = "Rank \(indexPath.row + 1)"
    }
    
    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "Unable to load event district points")
    }
    
    func hideNoDataView() {
        removeNoDataView()
    }
    
}
