import CoreData
import Foundation
import UIKit
import TBAKit
import FirebaseRemoteConfig

class DistrictsContainerViewController: ContainerViewController {

    private let remoteConfig: RemoteConfig
    private let urlOpener: URLOpener
    private let userDefaults: UserDefaults
    private var year: Int {
        didSet {
            districtsViewController!.year = year

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    private var districtsViewController: DistrictsViewController!

    override var viewControllers: [ContainableViewController] {
        return [districtsViewController]
    }

    // MARK: - Init

    init(remoteConfig: RemoteConfig, urlOpener: URLOpener, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.remoteConfig = remoteConfig
        self.urlOpener = urlOpener
        self.userDefaults = userDefaults

        year = remoteConfig.currentSeason

        super.init(persistentContainer: persistentContainer)

        title = "Districts"
        tabBarItem.image = UIImage(named: "ic_assignment")
        navigationTitleDelegate = self

        districtsViewController = DistrictsViewController(year: year, delegate: self, persistentContainer: persistentContainer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Shouldn't this have the same split view controller code the other root views do?

        navigationTitle = "Districts"
        updateInterface()
    }

    // MARK: - Private Methods

    private func updateInterface() {
        navigationSubtitle = "▾ \(year)"
    }

    private func showSelectYear() {
        let selectTableViewController = SelectTableViewController<DistrictsContainerViewController>(current: year, options: Array(2009...remoteConfig.maxSeason).reversed(), persistentContainer: persistentContainer)
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

extension DistrictsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        showSelectYear()
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
        let districtViewController = DistrictViewController(district: district, urlOpener: urlOpener, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(districtViewController, animated: true)
    }

}
