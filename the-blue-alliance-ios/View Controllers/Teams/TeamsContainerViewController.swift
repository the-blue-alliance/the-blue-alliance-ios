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

    init(myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener

        teamsViewController = TeamsViewController(refreshProvider: searchService, showSearch: false, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [teamsViewController],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "Teams"
        tabBarItem.image = UIImage.teamIcon

        teamsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("teams", parameters: nil)
    }

}

extension TeamsContainerViewController: TeamsViewControllerDelegate, SearchContainer, SearchContainerDelegate, SearchViewControllerDelegate {}
