import CoreData
import Firebase
import MyTBAKit
import TBAKit
import UIKit

class DistrictViewController: ContainerViewController {

    private(set) var district: District
    private let myTBA: MyTBA
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private(set) var eventsViewController: DistrictEventsViewController
    private(set) var teamsViewController: DistrictTeamsViewController
    private(set) var rankingsViewController: DistrictRankingsViewController

    // MARK: - Init

    init(district: District, myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.district = district
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        eventsViewController = DistrictEventsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        teamsViewController = DistrictTeamsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        rankingsViewController = DistrictRankingsViewController(district: district, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [eventsViewController, teamsViewController, rankingsViewController],
                   segmentedControlTitles: ["Events", "Teams", "Rankings"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "\(district.year!.stringValue) \(district.name!) Districts"

        eventsViewController.delegate = self
        teamsViewController.delegate = self
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("district", parameters: ["district": district.key!])
    }

}

extension DistrictViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

    func title(for event: Event) -> String? {
        return "\(event.title) Events"
    }

}

extension DistrictViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamViewController = TeamViewController(team: team, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamViewController, animated: true)
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
