import Foundation
import MyTBAKit
import TBAAPI
import TBAUtils
import UIKit

class DashboardContainerViewController: ContainerViewController {

    private(set) var dashboardViewController: DashboardViewController

    // MARK: - Init

    init(dependencies: Dependencies) {
        dashboardViewController = DashboardViewController(dependencies: dependencies)

        super.init(
            viewControllers: [dashboardViewController],
            navigationTitle: RootType.dashboard.title,
            dependencies: dependencies
        )

        navigationItem.backButtonTitle = RootType.dashboard.title
        tabBarItem.image = RootType.dashboard.icon
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Dashboard")
    }

}

extension DashboardContainerViewController: SearchContainerDelegate,
    SearchViewControllerDelegate
{}
