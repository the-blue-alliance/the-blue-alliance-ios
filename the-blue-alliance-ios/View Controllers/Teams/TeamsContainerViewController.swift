import Foundation
import UIKit
import CoreData
import TBAKit

private let TeamSegue = "TeamSegue"

class TeamsContainerViewController: ContainerViewController {

    private let urlOpener: URLOpener
    private var teamsViewController: TeamsViewController!

    override var viewControllers: [ContainableViewController] {
        return [teamsViewController]
    }

    // MARK: - Init

    init(urlOpener: URLOpener, persistentContainer: NSPersistentContainer) {
        self.urlOpener = urlOpener

        super.init(persistentContainer: persistentContainer)

        title = "Teams"
        tabBarItem.image = UIImage(named: "ic_people")

        teamsViewController = TeamsViewController(delegate: self, persistentContainer: persistentContainer)
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
