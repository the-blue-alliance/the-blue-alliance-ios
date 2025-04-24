import CoreData
import Foundation
import TBAAPI
import UIKit

protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: TBACollectionViewListController<UICollectionViewListCell, District> {

    // MARK: - Public Properties

    var year: Int {
        didSet {
            guard isViewLoaded else {
                return
            }
            refresh()
        }
    }

    weak var delegate: DistrictsViewControllerDelegate?

    // MARK: - Private Properties

    private let api: TBAAPI

    @SortedKeyPath(comparator: KeyPathComparator(\.name))
    private var districts: [District]? = nil {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateDataSource()
        }
    }

    // MARK: - Init

    init(year: Int, api: TBAAPI) {
        self.year = year
        self.api = api

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateDataSource()
    }

    // MARK: - Data Source

    override var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, District> {
        UICollectionView.CellRegistration(handler: { (cell, indexPath, district) in
            var contentConfig = cell.defaultContentConfiguration()
            contentConfig.text = district.name

            cell.contentConfiguration = contentConfig
            cell.accessories = [.disclosureIndicator()]
        })
    }

    @MainActor
    func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.insertSection("districts", atIndex: 0)
        if let districts {
            snapshot.appendItems(districts)
        }
        dataSource.apply(snapshot)
    }

    // MARK: - Refresh

    override func performRefresh() async throws {
        districts = try await api.getDistricts(year: year)
    }

    // MARK: UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let dataSource, let district = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.districtSelected(district)
    }

    // MARK: - Stateful

    override var noDataText: String? {
        return "No districts for year"
    }

}
