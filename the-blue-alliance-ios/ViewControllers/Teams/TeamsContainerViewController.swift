import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class TeamsContainerViewController: ContainerViewController {

    private(set) var myTBA: MyTBA
    private(set) var myTBAStores: MyTBAStores
    private(set) var pasteboard: UIPasteboard?
    private(set) var photoLibrary: PHPhotoLibrary?
    private(set) var statusService: StatusService
    private(set) var urlOpener: URLOpener

    var searchController: UISearchController!

    private(set) var teamsViewController: TeamsViewController!

    // MARK: - Init

    init(myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        teamsViewController = TeamsViewController(showSearch: false, dependencies: dependencies)

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
            setupSearchController()
        }
    }

}

extension TeamsContainerViewController: TeamsListViewControllerDelegate, SearchContainer, SearchContainerDelegate, SearchViewControllerDelegate {
}
