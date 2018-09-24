import Foundation
import UIKit
import CoreData
import TBAKit

private let TeamSegue = "TeamSegue"

class TeamsContainerViewController: ContainerViewController {

    init(persistentContainer: NSPersistentContainer) {
        super.init(persistentContainer: persistentContainer)

        title = "Teams"
        tabBarItem.image = UIImage(named: "ic_people")

        let teamsViewController = TeamsTableViewController(teamSelected: { [unowned self] (team) in
            let teamViewController = TeamViewController(team: team, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(teamViewController, animated: true)
            }, persistentContainer: persistentContainer)

        viewControllers = [teamsViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
