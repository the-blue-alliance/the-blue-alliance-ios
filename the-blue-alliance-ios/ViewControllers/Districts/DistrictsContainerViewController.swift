import Firebase
import Foundation
import TBAAPI
import MyTBAKit
import UIKit

// TODO: This could probably conform to some "Root" view or "Tabbed" view and setup all the tab related stuff...

class DistrictsContainerViewController: SimpleContainerViewController {

    private let statusService: StatusService

    private(set) var year: Int {
        didSet {
            guard isViewLoaded else {
                return
            }
            navigationSubtitle = ContainerViewController.yearSubtitle(year)
            districtsViewController.year = year
        }
    }
    private lazy var districtsViewController: DistrictsViewController = {
        let districtsViewController = DistrictsViewController(year: year, api: api)
        districtsViewController.delegate = self
        return districtsViewController
    }()

    // MARK: - Init

    init(api: TBAAPI, statusService: StatusService) {
        self.statusService = statusService

        year = 2025

        super.init(api: api)

        navigationTitleDelegate = self

        // TODO: I HATE that this has to go here... but it does?

        tabBarItem.image = RootType.districts.icon
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitle = RootType.districts.title
        navigationSubtitle = ContainerViewController.yearSubtitle(year) // TODO: Can we DRY this?
    }

    // MARK: Container Data Source

    override var numberOfContainedViewControllers: Int {
        return 1
    }

    override func viewControllerForSegment(at index: Int) -> UIViewController {
        return districtsViewController
    }

}

extension DistrictsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        /*
        let selectTableViewController = SelectTableViewController<DistrictsContainerViewController>(current: year, options: Array(2009...statusService.maxSeason).reversed(), dependencies: dependencies)
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelectYear))

        navigationController?.present(nav, animated: true, completion: nil)
        */
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
        let districtViewController = DistrictContainerViewController(district: district, api: api)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: districtViewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(districtViewController, animated: true)
        }
    }

}
