//
//  DistrictRankingsTableViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/14/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import UIKit
import CoreData

class DistrictRankingsTableViewController: TBATableViewController {

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    var district: District!
    var rankingSelected: ((DistrictRanking) -> ())?
    
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
        
        // First things first... refresh all teams for the district, *then* fetch their rankings
        var request: URLSessionDataTask?
        request = TBADistrict.fetchTeamsForDistrict(key: district.key!, completion: { (teams, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                backgroundContext.performAndWait {
                    teams?.forEach({ (modelTeam) in
                        _ = Team.insert(with: modelTeam, in: backgroundContext)
                    })
                }
                _ = backgroundContext.saveOrRollback()
                
                var rankingsRequest: URLSessionDataTask?
                rankingsRequest = TBADistrict.fetchDistrictRankings(key: self.district.key!, completion: { (rankings, error) in
                    if let error = error {
                        self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
                    }
                    
                    self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                        let backgroundDistrict = backgroundContext.object(with: self.district.objectID) as! District

                        let localRankings = rankings?.flatMap({ (modelRanking) -> DistrictRanking? in
                            var backgroundTeam: Team?
                            backgroundContext.performAndWait {
                                backgroundTeam = Team.fetchSingleObject(in: backgroundContext, configure: { (fetchRequest) in
                                    fetchRequest.predicate = NSPredicate(format: "key == %@" , modelRanking.teamKey)
                                })
                            }
                            if let backgroundTeam = backgroundTeam {
                                return DistrictRanking.insert(with: modelRanking, for: backgroundDistrict, for: backgroundTeam, in: backgroundContext)
                            }
                            return nil
                        })
                        backgroundDistrict.addToRankings(Set(localRankings ?? []) as NSSet)
                        
                        if !backgroundContext.saveOrRollback() {
                            self.showErrorAlert(with: "Unable to refresh district rankings - database error")
                        }
                        
                        self.removeRequest(request: rankingsRequest!)
                    })
                })

                self.addRequest(request: rankingsRequest!)
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
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
    
    fileprivate var dataSource: TableViewDataSource<DistrictRanking, DistrictRankingsTableViewController>?
    
    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<DistrictRanking> = DistrictRanking.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        
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
    
    fileprivate func setupFetchRequest(_ request: NSFetchRequest<DistrictRanking>) {
        request.predicate = NSPredicate(format: "district == %@", district)
    }
    
}

extension DistrictRankingsTableViewController: TableViewDataSourceDelegate {
    
    func configure(_ cell: RankingTableViewCell, for object: DistrictRanking) {
        cell.ranking = object
    }
    
    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "Unable to load district rankings")
    }
    
    func hideNoDataView() {
        removeNoDataView()
    }
    
}
