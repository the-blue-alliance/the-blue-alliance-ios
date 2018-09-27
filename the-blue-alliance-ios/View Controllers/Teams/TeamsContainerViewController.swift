import Foundation
import UIKit
import CoreData
import TBAKit

private let TeamSegue = "TeamSegue"

class TeamsContainerViewController: ContainerViewController {

    private let urlOpener: URLOpener

    // MARK: - Init

    init(urlOpener: URLOpener, persistentContainer: NSPersistentContainer) {
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
        let teamViewController = TeamViewController(team: team, urlOpener: urlOpener, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamViewController, animated: true)
    }

}
