import CoreData
import Foundation
import UIKit
import TBAKit
import FirebaseRemoteConfig

class DistrictsContainerViewController: ContainerViewController {

    let maxYear: Int
    var year: Int = RemoteConfig.remoteConfig().currentSeason {
        didSet {
            districtsViewController!.year = year

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    private var districtsViewController: DistrictsTableViewController?

    // MARK: - Init

    init(remoteConfig: RemoteConfig, persistentContainer: NSPersistentContainer) {
        maxYear = remoteConfig.maxSeason
        year = remoteConfig.currentSeason

        super.init(persistentContainer: persistentContainer)

        title = "Districts"
        tabBarItem.image = UIImage(named: "ic_assignment")

        districtsViewController = DistrictsTableViewController(year: year, districtSelected: { [unowned self] (district) in
            let districtViewController = DistrictViewController(district: district, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(districtViewController, animated: true)
            }, persistentContainer: persistentContainer)

        viewControllers = [districtsViewController!]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateInterface()
    }

    // MARK: - Private Methods

    func updateInterface() {
        navigationTitleLabel.text = "Districts"
        navigationDetailLabel.text = "▾ \(year)"
    }

    func selectYear() {
        // TODO: Rework this SelectTableViewController so we pass this stuff in...
        let selectTableViewController = SelectTableViewController<Int>()
        selectTableViewController.title = "Select Year"
        selectTableViewController.current = year
        selectTableViewController.options = Array(2009...maxYear).reversed()
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
