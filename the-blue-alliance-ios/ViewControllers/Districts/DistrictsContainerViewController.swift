import Foundation
import MyTBAKit
import TBAAPI
import UIKit
import TBAUtils

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
            dependencies: dependencies
        )

        navigationItem.backButtonTitle = RootType.districts.title
        tabBarItem.image = RootType.districts.icon

        rightBarButtonItems = [UIBarButtonItem(pill: yearButton)]
        districtsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Districts: \(year)")
    }

    // MARK: - Private Methods

    private func updateInterface() {
        yearButton.configuration?.title = String(year)
    }

    private lazy var yearButton = UIButton.menuPill(title: String(year), menu: yearMenu())

    // Reading `maxSeason` here rebuilds the menu when `/status` loads after the button is built.
    override func updateProperties() {
        super.updateProperties()

        yearButton.menu = yearMenu()
    }

    private func yearMenu() -> UIMenu {
        UIMenu(
            options: .singleSelection,
            children: Array(2009...statusService.maxSeason).reversed().map { option in
                UIAction(title: String(option), state: option == year ? .on : .off) {
                    [weak self] _ in
                    self?.year = option
                }
            }
        )
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
