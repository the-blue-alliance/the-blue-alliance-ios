//
//  EventRankingsTableViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/14/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import UIKit
import CoreData

class EventRankingsTableViewController: TBATableViewController {

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    var event: Event!
    var rankingSelected: ((EventRanking) -> ())?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: EventRankingTableViewCell.self), bundle: nil), forCellReuseIdentifier: EventRankingTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    }
    
    // MARK: - Refreshing
    
    override func refresh() {
        removeNoDataView()
        var rankingsRequest: URLSessionDataTask?
        rankingsRequest = event.fetchEventRankings(key: self.event.key!, completion: { (rankings, sortOrder, extraStats, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event rankings - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                let realRankings = (rankings?["rankings"] as! [[String: Any]]).map { TBAEventRanking.init(json: $0) }
                
                let localRankings = realRankings.flatMap({ (modelRanking) -> EventRanking? in
                    var backgroundTeam: Team?
                    backgroundContext.performAndWait {
                        backgroundTeam = Team.fetchSingleObject(in: backgroundContext, configure: { (fetchRequest) in
                            fetchRequest.predicate = NSPredicate(format: "key == %@" , modelRanking!.teamKey)
                        })
                    }
                    if let backgroundTeam = backgroundTeam {
                        return EventRanking.insert(with: modelRanking!, for: backgroundEvent, for: backgroundTeam, in: backgroundContext)
                    }
                    return nil
                })
                backgroundEvent.rankings = Set(localRankings ) as NSSet
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event rankings - database error")
                }
                
                self.removeRequest(request: rankingsRequest!)
            })
        })
        
        self.addRequest(request: rankingsRequest!)
    }
    
    override func shouldNoDataRefresh() -> Bool {
        if let rankings = dataSource?.fetchedResultsController.fetchedObjects, rankings.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ranking = dataSource?.object(at: indexPath)
        if let ranking = ranking, let rankingSelected = rankingSelected {
            rankingSelected(ranking)
        }
    }
    
    // MARK: Table View Data Source
    
    fileprivate var dataSource: TableViewDataSource<EventRanking, EventRankingsTableViewController>?
    
    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<EventRanking> = EventRanking.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        
        setupFetchRequest(fetchRequest)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: EventRankingTableViewCell.reuseIdentifier, fetchedResultsController: frc, delegate: self)
    }
    
    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }
    
    fileprivate func setupFetchRequest(_ request: NSFetchRequest<EventRanking>) {
        request.predicate = NSPredicate(format: "event == %@", event)
    }
    
}

extension EventRankingsTableViewController: TableViewDataSourceDelegate {
    
    func configure(_ cell: EventRankingTableViewCell, for object: EventRanking) {
        cell.ranking = object
    }
    
    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "Unable to load event rankings")
    }
    
    func hideNoDataView() {
        removeNoDataView()
    }
    
}
