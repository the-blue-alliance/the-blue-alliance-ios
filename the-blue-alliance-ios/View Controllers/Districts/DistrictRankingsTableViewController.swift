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
        
    // MARK: - Refreshing
    
    // TODO: Think about building a way to "chain" requests together for a refresh...
    override func refresh() {
        removeNoDataView()
        
        // First, fetch events
        var eventRequest: URLSessionDataTask?
        eventRequest = refreshEvents { (success) in
            if !success {
                self.showErrorAlert(with: "Unable to refresh district rankings - database error")
                self.removeRequest(request: eventRequest!)
                return
            }

            // Fetch Teams
            var teamRequest: URLSessionDataTask?
            teamRequest = self.refreshTeams(completion: { (success) in
                if !success {
                    self.showErrorAlert(with: "Unable to refresh district rankings - database error")
                    self.removeRequest(request: teamRequest!)
                    return
                }
                
                // Fetch Rankings
                var rankingsRequest: URLSessionDataTask?
                rankingsRequest = self.refreshRankings(completion: { (success) in
                    if !success {
                        self.showErrorAlert(with: "Unable to refresh district rankings - database error")
                    }
                    
                    self.removeRequest(request: rankingsRequest!)
                })
                self.addRequest(request: rankingsRequest!)
                self.removeRequest(request: teamRequest!)
            })
            self.addRequest(request: teamRequest!)
            self.removeRequest(request: eventRequest!)
        }
        addRequest(request: eventRequest!)
    }
    
    func refreshEvents(completion: @escaping (_ success: Bool) -> ()) -> URLSessionDataTask {
        return TBAKit.sharedKit.fetchDistrictEvents(key: district.key!, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
                completion(false)
                return
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                backgroundContext.performAndWait {
                    events?.forEach({ (modelEvent) in
                        _ = Event.insert(with: modelEvent, in: backgroundContext)
                    })
                }
                let success = backgroundContext.saveOrRollback()
                completion(success)
            })
        })
    }
    
    func refreshTeams(completion: @escaping (_ success: Bool) -> ()) -> URLSessionDataTask {
        return TBAKit.sharedKit.fetchDistrictTeams(key: district.key!, completion: { (teams, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
                completion(false)
                return
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                backgroundContext.performAndWait {
                    teams?.forEach({ (modelTeam) in
                        _ = Team.insert(with: modelTeam, in: backgroundContext)
                    })
                }
                let success = backgroundContext.saveOrRollback()
                completion(success)
            })
        })
    }
    
    func refreshRankings(completion: @escaping (_ success: Bool) -> ()) -> URLSessionDataTask {
        return TBAKit.sharedKit.fetchDistrictRankings(key: district.key!, completion: { (rankings, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
                completion(false)
                return
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundDistrict = backgroundContext.object(with: self.district.objectID) as! District
                
                let localRankings = rankings?.compactMap({ (modelRanking) -> DistrictRanking? in
                    let backgroundTeam = Team.insert(withKey: modelRanking.teamKey, in: backgroundContext)
                    return DistrictRanking.insert(with: modelRanking, for: backgroundDistrict, for: backgroundTeam, in: backgroundContext)
                })
                backgroundDistrict.rankings = Set(localRankings ?? []) as NSSet
                
                let success = backgroundContext.saveOrRollback()
                completion(success)
            })
        })
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

    func configure(_ cell: RankingTableViewCell, for object: DistrictRanking, at indexPath: IndexPath) {
        cell.districtRanking = object
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
