import CoreData
import Firebase
import Foundation
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class DistrictsContainerViewController: ContainerViewController {

    private let myTBA: MyTBA
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

    init(myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        year = statusService.currentSeason
        districtsViewController = DistrictsViewController(year: year, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [districtsViewController],
                   navigationTitle: "Districts",
                   navigationSubtitle: ContainerViewController.yearSubtitle(year),
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "Districts"
        tabBarItem.image = UIImage.districtIcon

        navigationTitleDelegate = self
        districtsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    // MARK: - Private Methods

    private func updateInterface() {
        navigationSubtitle = ContainerViewController.yearSubtitle(year)
    }

}

extension DistrictsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        let selectTableViewController = SelectTableViewController<DistrictsContainerViewController>(current: year, options: Array(2009...statusService.maxSeason).reversed(), persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
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

    func districtSelected(_ district: District) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let districtViewController = DistrictViewController(district: district, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let nav = UINavigationController(rootViewController: districtViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}
