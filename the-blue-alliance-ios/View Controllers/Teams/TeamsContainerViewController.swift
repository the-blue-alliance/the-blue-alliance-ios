import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class TeamsContainerViewController: ContainerViewController {

    private let myTBA: MyTBA
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private(set) var teamsViewController: TeamsViewController!

    // MARK: - Init

    init(myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        teamsViewController = TeamsViewController(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("teams", parameters: nil)
    }

}

extension TeamsContainerViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let teamViewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let nav = UINavigationController(rootViewController: teamViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}
