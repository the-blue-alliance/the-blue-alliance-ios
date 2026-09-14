import MyTBAKit
import Photos
import UIKit
import TBAUtils

class TeamsContainerViewController: ContainerViewController {

    let teamsViewController: TeamsViewController

    // MARK: - Init

    init(dependencies: Dependencies) {

        teamsViewController = TeamsViewController(dependencies: dependencies)

        super.init(viewControllers: [teamsViewController], dependencies: dependencies)

        title = RootType.teams.title
        tabBarItem.image = RootType.teams.icon

        teamsViewController.delegate = self
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

        dependencies.reporter.log("Teams")
    }

}

extension TeamsContainerViewController: TeamsListViewControllerDelegate, SearchContainerDelegate,
    SearchViewControllerDelegate
{
}
