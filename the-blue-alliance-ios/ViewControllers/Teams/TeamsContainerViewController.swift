import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class TeamsContainerViewController: ContainerViewController {

    private(set) var myTBA: MyTBA
    private(set) var pasteboard: UIPasteboard?
    private(set) var photoLibrary: PHPhotoLibrary?
    private(set) var statusService: StatusService
    private(set) var urlOpener: URLOpener

    var searchController: UISearchController!

    private(set) var teamsViewController: TeamsViewController!

    // MARK: - Init

    init(myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

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

        // Only show Search in container view on iPhone
        if UIDevice.isPhone {
            // setupSearchController()
        }
    }

}

extension TeamsContainerViewController: TeamsViewControllerDelegate {
    func teamSelected(_ team: Team) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let teamViewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        if let splitViewController = splitViewController {
            let navigationController = UINavigationController(rootViewController: teamViewController)
            splitViewController.showDetailViewController(navigationController, sender: nil)
        } else if let navigationController = navigationController {
            navigationController.pushViewController(teamViewController, animated: true)
        }
    }
}
