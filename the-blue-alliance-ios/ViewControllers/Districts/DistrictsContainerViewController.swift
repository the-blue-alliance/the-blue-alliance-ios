import Foundation
import MyTBAKit
import TBAAPI
import UIKit

class DistrictsContainerViewController: ContainerViewController {

    private let myTBA: MyTBA
    private let myTBAStores: MyTBAStores
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private(set) var year: Int {
        didSet {
            districtsViewController.year = year
            updateInterface()
        }
    }
    private(set) var districtsViewController: DistrictsViewController

    // MARK: - Init

    init(myTBA: MyTBA, myTBAStores: MyTBAStores, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.statusService = statusService
        self.urlOpener = urlOpener

        year = statusService.currentSeason
        districtsViewController = DistrictsViewController(year: year, dependencies: dependencies)

        super.init(viewControllers: [districtsViewController],
                   navigationTitle: "Districts",
                   navigationSubtitle: ContainerViewController.yearSubtitle(year),
                   dependencies: dependencies)

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
        let selectTableViewController = SelectTableViewController<DistrictsContainerViewController>(current: year, options: Array(2009...statusService.maxSeason).reversed(), dependencies: dependencies)
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelectYear))

        navigationController?.present(nav, animated: true, completion: nil)
    }

    @objc private func dismissSelectYear() {
        navigationController?.dismiss(animated: true, completion: nil)
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

    func districtSelected(_ district: Components.Schemas.District) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let districtViewController = DistrictViewController(district: district, myTBA: myTBA, myTBAStores: myTBAStores, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: districtViewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(districtViewController, animated: true)
        }
    }

}
