import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

protocol DistrictRankingsViewControllerDelegate: AnyObject {
    func districtRankingSelected(_ districtRanking: DistrictRanking)
}

class DistrictRankingsViewController: TBASearchableTableViewController {

    weak var delegate: DistrictRankingsViewControllerDelegate?

    private let district: District

    private var dataSource: TableViewDataSource<String, DistrictRanking>!
    private var fetchedResultsController: TableViewDataSourceFetchedResultsController<DistrictRanking>!

    // MARK: - Init

    init(district: District, dependencies: Dependencies) {
        self.district = district

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearch()

        tableView.registerReusableCell(RankingTableViewCell.self)

        tableView.dataSource = dataSource
        setupDataSource()
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
        dataSource = TableViewDataSource<String, DistrictRanking>(tableView: tableView) { (tableView, indexPath, districtRanking) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RankingTableViewCell
            cell.viewModel = RankingCellViewModel(districtRanking: districtRanking)
            return cell
        }
        dataSource.statefulDelegate = self

        let fetchRequest: NSFetchRequest<DistrictRanking> = DistrictRanking.fetchRequest()
        fetchRequest.sortDescriptors = [
            DistrictRanking.rankSortDescriptor()
        ]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = TableViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)

        // Keep this LOC down here - or else we'll end up crashing with the fetchedResultsController init
        dataSource.delegate = self
    }

    override func updateDataSource() {
        fetchedResultsController.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<DistrictRanking>) {
        let searchPredicate: NSPredicate? = {
            guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
                return nil
            }
            return DistrictRanking.teamSearchPredicate(searchText: searchText)
        }()
        let predicate = DistrictRanking.districtPredicate(districtKey: district.key)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            predicate,
            searchPredicate
        ].compactMap({ $0 }))
    }

}

extension DistrictRankingsViewController: Refreshable {

    var refreshKey: String? {
        return "\(district.key)_rankings"
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
        operation = tbaKit.fetchDistrictRankings(key: district.key) { [self] (result, notModified) in
            guard case .success(let rankings) = result, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                let district = context.object(with: self.district.objectID) as! District
                district.insert(rankings)
            }, saved: { [unowned self] in
                markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        }
        addRefreshOperations([operation])
    }

}

extension DistrictRankingsViewController: Stateful {

    var noDataText: String? {
        return "No rankings for district"
    }

}
