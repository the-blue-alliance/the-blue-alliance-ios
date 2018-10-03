import CoreData
import FirebaseRemoteConfig
import Foundation
import TBAKit
import UIKit

class TeamsContainerViewController: ContainerViewController {

    private let remoteConfig: RemoteConfig
    private let urlOpener: URLOpener

    // MARK: - Init

    init(remoteConfig: RemoteConfig, urlOpener: URLOpener, persistentContainer: NSPersistentContainer) {
        self.remoteConfig = remoteConfig
        self.urlOpener = urlOpener

        let teamsViewController = TeamsViewController(persistentContainer: persistentContainer)

        super.init(viewControllers: [teamsViewController],
                   persistentContainer: persistentContainer)

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
        let teamViewController = TeamViewController(team: team, remoteConfig: remoteConfig, urlOpener: urlOpener, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamViewController, animated: true)
    }

}
