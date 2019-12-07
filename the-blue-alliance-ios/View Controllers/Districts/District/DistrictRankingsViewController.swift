import CoreData
import Crashlytics
import Foundation
import TBAData
import TBAKit
import UIKit

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ districtRanking: DistrictRanking)
}

class DistrictRankingsViewController: TBATableViewController {

    weak var delegate: DistrictRankingsViewControllerDelegate?

    private let district: District

    private var dataSource: TableViewDataSource<String, DistrictRanking>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<DistrictRanking>!

    // MARK: - Init

    init(district: District, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.district = district

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(RankingTableViewCell.self)

        setupDataSource()
        tableView.dataSource = dataSource
    }

    // MARK: UITableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ranking = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.districtRankingSelected(ranking)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let dataSource = UITableViewDiffableDataSource<String, DistrictRanking>(tableView: tableView) { (tableView, indexPath, districtRanking) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            cell.viewModel = RankingCellViewModel(districtRanking: districtRanking)
            return cell
        }
        self.dataSource = TableViewDataSource(dataSource: dataSource)
        self.dataSource.delegate = self

        let fetchRequest: NSFetchRequest<DistrictRanking> = DistrictRanking.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(DistrictRanking.rank), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(DistrictRanking.district), district)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

}

extension DistrictRankingsViewController: Refreshable {

    var refreshKey: String? {
        let key = district.getValue(\District.key!)
        return "\(key)_rankings"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh district rankings until DCMP is over
        return district.endDate?.endOfDay()
    }

    var isDataSourceEmpty: Bool {
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchDistrictRankings(key: district.key!) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let rankings = try? result.get() {
                    let district = context.object(with: self.district.objectID) as! District
                    district.insert(rankings)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        addRefreshOperations([operation])
    }

}

extension DistrictRankingsViewController: Stateful {

    var noDataText: String {
        return "No rankings for district"
    }

}
