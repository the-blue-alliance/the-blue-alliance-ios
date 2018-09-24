import CoreData
import Foundation
import UIKit

class DistrictViewController: ContainerViewController {

    let district: District

    // MARK: - Init

    init(district: District, persistentContainer: NSPersistentContainer) {
        self.district = district

        super.init(segmentedControlTitles: ["Events", "Rankings"],
                   persistentContainer: persistentContainer)

        let eventsViewController = EventsTableViewController(district: district, eventSelected: { [unowned self] (event) in
            let eventViewController = EventViewController(event: event, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(eventViewController, animated: true)
            }, persistentContainer: persistentContainer)

        let rankingsViewController = DistrictRankingsTableViewController(district: district, rankingSelected: { [unowned self] (ranking) in
            let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: ranking, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
            }, persistentContainer: persistentContainer)

        viewControllers = [eventsViewController, rankingsViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(district.year) \(district.name!) Districts"

        // TODO: Why do we do this? Has to do with the split view I know
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
    }

}
