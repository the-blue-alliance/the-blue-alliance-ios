import CoreData
import FirebaseRemoteConfig
import Foundation
import UIKit

class TeamsContainerViewController: ContainerViewController {

    private let myTBA: MyTBA
    private let remoteConfig: RemoteConfig
    private let urlOpener: URLOpener

    private(set) var teamsViewController: TeamsViewController!

    // MARK: - Init

    init(myTBA: MyTBA, remoteConfig: RemoteConfig, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.myTBA = myTBA
        self.remoteConfig = remoteConfig
        self.urlOpener = urlOpener

        teamsViewController = TeamsViewController(persistentContainer: persistentContainer, tbaKit: tbaKit)

        super.init(viewControllers: [teamsViewController],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit)

        teamsViewController.delegate = self

        title = "Teams"
        tabBarItem.image = UIImage(named: "ic_people")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TeamsContainerViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let teamViewController = TeamViewController(team: team, myTBA: myTBA, remoteConfig: remoteConfig, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit)
        let nav = UINavigationController(rootViewController: teamViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}
