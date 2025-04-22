import CoreData
import Foundation
import TBAAPI
import TBAModels
import UIKit

protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: TBAFakeTableViewController {

    var year: Int {
        didSet {
            guard isViewLoaded else {
                return
            }
            refresh()
        }
    }

    weak var delegate: DistrictsViewControllerDelegate?

    private var dataSource: CollectionViewDataSource<String, District>!
    @SortedKeyPath(comparator: KeyPathComparator(\District.name)) private var districts: [District]? = nil {
        didSet {
            updateDataSource()
        }
    }

    // MARK: - Init

    init(year: Int, dependencies: Dependencies) {
        self.year = year

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = dataSource
        setupDataSource()
    }

    // TODO: MOVE THIS ELSEWHERE

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refresh()
    }

    // MARK: UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let district = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.districtSelected(district)
    }

    // MARK: Collection View Data Source

    private func setupDataSource () {
        dataSource = CollectionViewDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, district in
            let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as ListCollectionViewCell
            var contentConfig = cell.defaultContentConfiguration()
            contentConfig.text = district.name

            cell.contentConfiguration = contentConfig
            cell.accessories = [.disclosureIndicator()]

            return cell
        })
        dataSource.statefulDelegate = self
    }

    @MainActor private func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.insertSection("districts", atIndex: 0)
        if let districts {
            snapshot.appendItems(districts)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - SimpleRefreshable

    override func performRefresh() async throws {
        self.districts = try await api.getDistricts(year: self.year)
    }
}

extension DistrictsViewController: Stateful {
    var noDataText: String? {
        return "No districts for year"
    }
}
