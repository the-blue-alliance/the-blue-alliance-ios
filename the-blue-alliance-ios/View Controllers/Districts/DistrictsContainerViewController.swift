import CoreData
import Foundation
import UIKit
import TBAKit
import FirebaseRemoteConfig

class DistrictsContainerViewController: ContainerViewController {

    private let remoteConfig: RemoteConfig
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

    init(remoteConfig: RemoteConfig, persistentContainer: NSPersistentContainer) {
        self.remoteConfig = remoteConfig
        year = remoteConfig.currentSeason

        super.init(persistentContainer: persistentContainer)

        title = "Districts"
        tabBarItem.image = UIImage(named: "ic_assignment")

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

    func updateInterface() {
        navigationSubtitle = "▾ \(year)"
    }

    func selectYear() {
        // TODO: Rework this SelectTableViewController so we pass this stuff in...
        let selectTableViewController = SelectTableViewController<Int>()
        selectTableViewController.title = "Select Year"
        selectTableViewController.current = year
        selectTableViewController.options = Array(2009...remoteConfig.maxSeason).reversed()
        selectTableViewController.optionSelected = { [unowned self] year in
            self.year = year
        }
        selectTableViewController.optionString = { year in
            return String(year)
        }

        let navigationController = UINavigationController(rootViewController: selectTableViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }

}

extension DistrictsContainerViewController: DistrictsViewControllerDelegate {

    func districtSelected(_ district: District) {
        let districtViewController = DistrictViewController(district: district, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(districtViewController, animated: true)
    }

}
