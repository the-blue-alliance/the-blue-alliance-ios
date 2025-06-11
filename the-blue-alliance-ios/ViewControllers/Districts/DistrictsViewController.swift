import Foundation
import TBAAPI
import SwiftUI
import UIKit

@MainActor protocol DistrictsViewControllerDelegate: AnyObject {
    func districtSelected(_ district: District)
}

class DistrictsViewController: ContainerViewController {

    private(set) var year: Int {
        didSet {
            guard isViewLoaded else {
                return
            }
            navigationSubtitle = String(year)
            districtsViewController.year = year
        }
    }
    private lazy var districtsViewController: DistrictsCollectionViewController = {
        let districtsViewController = DistrictsCollectionViewController(
            year: year,
            dependencyProvider: dependencyProvider
        )
        districtsViewController.delegate = self
        return districtsViewController
    }()

    // MARK: - Init

    override init(dependencyProvider: DependencyProvider) {
        year = dependencyProvider.statusService.currentSeason

        super.init(dependencyProvider: dependencyProvider)

        navigationTitleDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitle = RootType.districts.title
        navigationSubtitle = String(year)
    }

    // MARK: Container Data Source

    override var numberOfContainedViewControllers: Int {
        return 1
    }

    override func viewControllerForSegment(at index: Int) -> UIViewController {
        return districtsViewController
    }

}

extension DistrictsViewController: NavigationTitleDelegate {

    @MainActor
    func navigationTitleViewTapped() {
        guard let dependencyProvider = dependencyProvider else { return }
        let statusService = dependencyProvider.statusService
        let yearSelectView = YearSelectView(year: year, minSeason: 2009, maxSeason: statusService.maxSeason) { [weak self] selectedYear in
            self?.year = selectedYear
        }
        let hostingController = UIHostingController(rootView: yearSelectView)
        hostingController.modalPresentationStyle = .pageSheet

        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(hostingController, animated: true)
    }

    @objc private func dismissSelectYear() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}

/*
extension DistrictsViewController: SelectTableViewControllerDelegate {

    typealias OptionType = Int

    func optionSelected(_ option: OptionType) {
        year = option
    }

    func titleForOption(_ option: OptionType) -> String {
        return String(option)
    }

}
*/

extension DistrictsViewController: DistrictsViewControllerDelegate {

    func districtSelected(_ district: District) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let districtViewController = DistrictViewController(district: district, dependencyProvider: dependencyProvider)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: districtViewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(districtViewController, animated: true)
        }
    }

}

class DistrictsCollectionViewController: TBACollectionViewListController<UICollectionViewListCell, District> {

    // MARK: - Public Properties

    var year: Int {
        didSet {
            guard isViewLoaded else {
                return
            }
            districts = nil
            refresh()
        }
    }

    weak var delegate: DistrictsViewControllerDelegate?

    // MARK: - Private Properties

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

    init(year: Int, dependencyProvider: DependencyProvider) {
        self.year = year

        super.init(dependencyProvider: dependencyProvider)
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
        snapshot.appendSections(["districts"])
        if let districts {
            snapshot.appendItems(districts)
        }
        dataSource.apply(snapshot)
    }

    // MARK: - Refresh

    override func performRefresh() async throws {
        guard let api = dependencyProvider?.api else { return }
        let response = try await api.getDistrictsByYear(path: .init(year: year))
        districts = try response.ok.body.json
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
