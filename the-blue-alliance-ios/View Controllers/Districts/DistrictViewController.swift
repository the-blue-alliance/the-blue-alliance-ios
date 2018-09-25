import CoreData
import Foundation
import UIKit

class DistrictViewController: ContainerViewController {

    private let district: District

    private var eventsViewController: EventsViewController!
    private var rankingsViewController: DistrictRankingsViewController!

    override var viewControllers: [Refreshable & Stateful] {
        return [eventsViewController, rankingsViewController]
    }

    // MARK: - Init

    init(district: District, persistentContainer: NSPersistentContainer) {
        self.district = district

        super.init(segmentedControlTitles: ["Events", "Rankings"],
                   persistentContainer: persistentContainer)

        hidesBottomBarWhenPushed = true

        eventsViewController = EventsViewController(district: district, delegate: self, persistentContainer: persistentContainer)
        rankingsViewController = DistrictRankingsViewController(district: district, delegate: self, persistentContainer: persistentContainer)
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

extension DistrictViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
