import CoreData
import Foundation
import UIKit

class DistrictViewController: ContainerViewController {

    private(set) var district: District
    private let myTBA: MyTBA
    private let urlOpener: URLOpener

    private(set) var eventsViewController: DistrictEventsViewController
    private(set) var rankingsViewController: DistrictRankingsViewController

    // MARK: - Init

    init(district: District, myTBA: MyTBA, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.district = district
        self.myTBA = myTBA
        self.urlOpener = urlOpener

        eventsViewController = DistrictEventsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        rankingsViewController = DistrictRankingsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [eventsViewController, rankingsViewController],
                   segmentedControlTitles: ["Events", "Rankings"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "\(district.year!.stringValue) \(district.name!) Districts"

        eventsViewController.delegate = self
        rankingsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)
    }

}

extension DistrictViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

    func title(for event: Event) -> String? {
        return "\(event.weekString) Events"
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
