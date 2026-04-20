import Foundation
import MyTBAKit
import TBAAPI
import UIKit

class DistrictsContainerViewController: ContainerViewController {

    private(set) var year: Int {
        didSet {
            districtsViewController.year = year
            updateInterface()
        }
    }
    private(set) var districtsViewController: DistrictsViewController

    // MARK: - Init

    init(dependencies: Dependencies) {

        year = dependencies.statusService.currentSeason
        districtsViewController = DistrictsViewController(year: year, dependencies: dependencies)

        super.init(
            viewControllers: [districtsViewController],
            navigationTitle: "Districts",
            navigationSubtitle: ContainerViewController.yearSubtitle(year),
            dependencies: dependencies
        )

        title = RootType.districts.title
        tabBarItem.image = RootType.districts.icon

        navigationTitleDelegate = self
        districtsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func updateInterface() {
        navigationSubtitle = ContainerViewController.yearSubtitle(year)
    }

}

extension DistrictsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        let selectTableViewController = SelectTableViewController<DistrictsContainerViewController>(
            current: year,
            options: Array(2009...statusService.maxSeason).reversed(),
            dependencies: dependencies
        )
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )

        navigationController?.present(nav, animated: true)
    }

}

extension DistrictsContainerViewController: SelectTableViewControllerDelegate {

    typealias OptionType = Int

    func optionSelected(_ option: OptionType) {
        year = option
    }

    func titleForOption(_ option: OptionType) -> String {
        return String(option)
    }

}

extension DistrictsContainerViewController: DistrictsViewControllerDelegate {

    func districtSelected(_ district: District) {
        let districtViewController = DistrictViewController(
            district: district,
            dependencies: dependencies
        )
        navigationController?.pushViewController(districtViewController, animated: true)
    }

}
