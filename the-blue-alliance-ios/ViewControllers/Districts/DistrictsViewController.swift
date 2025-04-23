import CoreData
import Foundation
import TBAAPI
import TBAModels
import UIKit

protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: TBAFakeTableViewController<String, District> {

    var year: Int {
        didSet {
            guard isViewLoaded else {
                return
            }
            refresh()
        }
    }

    weak var delegate: DistrictsViewControllerDelegate?

    @SortedKeyPath(comparator: KeyPathComparator(\.name))
    private var districts: [District]? = nil {
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

        setupDataSource()
    }

    // MARK: UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let dataSource, let district = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.districtSelected(district)
    }

    // MARK: Collection View Data Source

    private func setupDataSource () {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, District>(handler: { (cell, indexPath, district) in
            var contentConfig = cell.defaultContentConfiguration()
            contentConfig.text = district.name

            cell.contentConfiguration = contentConfig
            cell.accessories = [.disclosureIndicator()]
        })
        dataSource = CollectionViewDataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, district: District) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: district)
        }
    }

    // TODO: This needs to move... elsewhere
    @MainActor private func updateDataSource() {
        guard let dataSource else {
            showNoDataView()
            return
        }

        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.insertSection("districts", atIndex: 0)
        if let districts {
            snapshot.appendItems(districts)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // MARK: - Refresh

    override func performRefresh() async throws {
        districts = try await api.getDistricts(year: self.year)
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No districts for year"
    }

}
