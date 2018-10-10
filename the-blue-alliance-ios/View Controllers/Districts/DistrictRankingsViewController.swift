import Foundation
import TBAKit
import UIKit
import CoreData

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ districtRanking: DistrictRanking)
}

class DistrictRankingsViewController: TBATableViewController, Refreshable {

    private let district: District

    weak var delegate: DistrictRankingsViewControllerDelegate?
    private var dataSource: TableViewDataSource<DistrictRanking, DistrictRankingsViewController>!

    // MARK: - Init

    init(district: District, persistentContainer: NSPersistentContainer) {
        self.district = district

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        return "\(district.key!)_rankings"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh district rankings until DCMP is over
        return district.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        if let rankings = dataSource.fetchedResultsController.fetchedObjects, rankings.isEmpty {
            return true
        }
        return false
    }

    // TODO: Think about building a way to "chain" requests together for a refresh...
    @objc func refresh() {
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
                    } else {
                        self.markRefreshSuccessful()
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

    private func refreshEvents(completion: @escaping (_ success: Bool) -> Void) -> URLSessionDataTask {
        return TBAKit.sharedKit.fetchDistrictEvents(key: district.key!, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
                completion(false)
                return
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.performAndWait {
                    events?.forEach({ (modelEvent) in
                        Event.insert(with: modelEvent, in: backgroundContext)
                    })
                }
                backgroundContext.saveOrRollback()
                completion(true)
            })
        })
    }

    private func refreshTeams(completion: @escaping (_ success: Bool) -> Void) -> URLSessionDataTask {
        return TBAKit.sharedKit.fetchDistrictTeams(key: district.key!, completion: { (teams, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
                completion(false)
                return
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.performAndWait {
                    teams?.forEach({ (modelTeam) in
                        Team.insert(with: modelTeam, in: backgroundContext)
                    })
                }
                backgroundContext.saveOrRollback()
                completion(true)
            })
        })
    }

    private func refreshRankings(completion: @escaping (_ success: Bool) -> Void) -> URLSessionDataTask {
        return TBAKit.sharedKit.fetchDistrictRankings(key: district.key!, completion: { (rankings, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh district rankings - \(error.localizedDescription)")
                completion(false)
                return
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundDistrict = backgroundContext.object(with: self.district.objectID) as! District
                rankings?.forEach({ (modelRanking) in
                    let backgroundTeam = Team.insert(withKey: modelRanking.teamKey, in: backgroundContext)
                    DistrictRanking.insert(with: modelRanking, for: backgroundDistrict, for: backgroundTeam, in: backgroundContext)
                })

                backgroundContext.saveOrRollback()
                completion(true)
            })
        })
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ranking = dataSource.object(at: indexPath)
        delegate?.districtRankingSelected(ranking)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<DistrictRanking> = DistrictRanking.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<DistrictRanking>) {
        request.predicate = NSPredicate(format: "district == %@", district)
    }

}

extension DistrictRankingsViewController: TableViewDataSourceDelegate {

    func configure(_ cell: RankingTableViewCell, for object: DistrictRanking, at indexPath: IndexPath) {
        cell.viewModel = RankingCellViewModel(districtRanking: object)
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
