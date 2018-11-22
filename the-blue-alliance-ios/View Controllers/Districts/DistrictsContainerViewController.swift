import CoreData
import Foundation
import UIKit
import FirebaseRemoteConfig

class DistrictsContainerViewController: ContainerViewController {

    private let myTBA: MyTBA
    private let remoteConfig: RemoteConfig
    private let urlOpener: URLOpener
    private let userDefaults: UserDefaults

    private(set) var year: Int {
        didSet {
            districtsViewController.year = year

            updateInterface()
        }
    }
    private(set) var districtsViewController: DistrictsViewController

    // MARK: - Init

    init(myTBA: MyTBA, remoteConfig: RemoteConfig, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.myTBA = myTBA
        self.remoteConfig = remoteConfig
        self.urlOpener = urlOpener
        self.userDefaults = userDefaults

        year = remoteConfig.currentSeason
        districtsViewController = DistrictsViewController(year: year, persistentContainer: persistentContainer, tbaKit: tbaKit)

        super.init(viewControllers: [districtsViewController],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit)

        title = "Districts"
        tabBarItem.image = UIImage(named: "ic_assignment")
        navigationTitle = "Districts"
        updateInterface()

        navigationTitleDelegate = self
        districtsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func updateInterface() {
        navigationSubtitle = "▾ \(year)"
    }

}

extension DistrictsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        let selectTableViewController = SelectTableViewController<DistrictsContainerViewController>(current: year, options: Array(2009...remoteConfig.maxSeason).reversed(), persistentContainer: persistentContainer, tbaKit: tbaKit)
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
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
        let districtViewController = DistrictViewController(district: district, myTBA: myTBA, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer, tbaKit: tbaKit)
        let nav = UINavigationController(rootViewController: districtViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}
