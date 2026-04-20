import MyTBAKit
import Photos
import TBAAPI
import UIKit

class DistrictViewController: ContainerViewController {

    private(set) var district: District
    private let year: Int

    private(set) var eventsViewController: DistrictEventsViewController
    private(set) var teamsViewController: DistrictTeamsViewController
    private(set) var rankingsViewController: DistrictRankingsViewController

    // MARK: - Init

    init(district: District, year: Int? = nil, dependencies: Dependencies) {
        self.district = district
        // District keys look like `2023fim` — year is the first 4 chars.
        let parsedYear =
            year ?? Int(district.key.prefix(4)) ?? dependencies.statusService.currentSeason
        self.year = parsedYear

        eventsViewController = DistrictEventsViewController(
            districtKey: district.key,
            year: parsedYear,
            dependencies: dependencies
        )
        teamsViewController = DistrictTeamsViewController(
            districtKey: district.key,
            year: parsedYear,
            dependencies: dependencies
        )
        rankingsViewController = DistrictRankingsViewController(
            districtKey: district.key,
            dependencies: dependencies
        )

        super.init(
            viewControllers: [eventsViewController, teamsViewController, rankingsViewController],
            segmentedControlTitles: ["Events", "Teams", "Rankings"],
            dependencies: dependencies
        )

        title = "\(parsedYear) \(district.displayName) Districts"

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
    }

}

extension DistrictViewController: EventsListViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let eventViewController = EventViewController(event: event, dependencies: dependencies)
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }

    func title(for event: Event) -> String? {
        "\(event.weekString) Events"
    }

}

extension DistrictViewController: TeamsListViewControllerDelegate {

    func teamSelected(_ team: any TeamDisplayable) {
        let teamViewController = TeamViewController(
            teamKey: team.key,
            nickname: team.nickname,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(teamViewController, animated: true)
    }

}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ ranking: DistrictRanking) {
        let teamAtDistrictViewController = TeamAtDistrictViewController(
            ranking: ranking,
            district: district,
            year: year,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
    }

}
