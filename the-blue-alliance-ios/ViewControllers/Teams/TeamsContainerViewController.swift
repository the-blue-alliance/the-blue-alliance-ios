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
    private(set) var searchService: SearchService
    private(set) var statusService: StatusService
    private(set) var urlOpener: URLOpener

    var searchController: UISearchController!

    private(set) var teamsViewController: TeamsViewController!

    // MARK: - Init

    init(myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener

        teamsViewController = TeamsViewController(refreshProvider: searchService, showSearch: false, dependencies: dependencies)

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

extension TeamsContainerViewController: TeamsViewControllerDelegate, SearchContainer, SearchContainerDelegate, SearchViewControllerDelegate {}
