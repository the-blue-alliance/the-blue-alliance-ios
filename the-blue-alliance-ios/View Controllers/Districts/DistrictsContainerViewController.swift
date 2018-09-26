import CoreData
import Foundation
import UIKit
import TBAKit
import FirebaseRemoteConfig

class DistrictsContainerViewController: ContainerViewController {

    typealias OptionType = Int

    private let remoteConfig: RemoteConfig
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

    init(remoteConfig: RemoteConfig, userDefaults: UserDefaults, persistentContainer: NSPersistentContainer) {
        self.remoteConfig = remoteConfig
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
        let selectViewController = SelectViewController<DistrictsContainerViewController>(current: year, options: Array(2009...remoteConfig.maxSeason).reversed())
        selectViewController.title = "Select Year"
        selectViewController.selectTableViewControllerDelegate = self
        navigationController?.present(selectViewController, animated: true, completion: nil)
    }

}

extension DistrictsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        showSelectYear()
    }

}

extension DistrictsContainerViewController: SelectTableViewControllerDelegate {

    func optionSelected(_ option: OptionType) {
        year = option
    }

    func titleForOption(_ option: OptionType) -> String {
        return String(year)
    }

}

extension DistrictsContainerViewController: DistrictsViewControllerDelegate {

    func districtSelected(_ district: District) {
        let districtViewController = DistrictViewController(district: district, userDefaults: userDefaults, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(districtViewController, animated: true)
    }

}
