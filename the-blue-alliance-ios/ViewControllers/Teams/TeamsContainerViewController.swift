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

    // Navigation from the new API-driven top-level teams list.
    func teamSelected(teamKey: String) {
        // TODO(phase-3b): push TeamViewController(teamKey:) directly.
        // Phase 3a still lands a managed Team via `Team.insert` so the legacy
        // TeamViewController can display. Phase 3b rewrites TeamViewController
        // to take `teamKey: String` and removes this bridge.
        let team = Team.insert(teamKey, in: persistentContainer.viewContext)
        teamSelected(team)
    }
}
