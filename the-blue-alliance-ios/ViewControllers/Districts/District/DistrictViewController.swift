import TBAAPI
import UIKit

private enum DistrictView: Int, CaseIterable {
    case events
    case teams
    case rankings
}

class DistrictViewController: ContainerViewController {

    private let district: District

    private lazy var eventsViewController: DistrictEventsViewController = {
        let eventsViewController = DistrictEventsViewController(
            district: district,
            dependencyProvider: dependencyProvider
        )
        eventsViewController.delegate = self
        return eventsViewController
    }()
    private lazy var teamsViewController: DistrictTeamsViewController = {
        let teamsViewController = DistrictTeamsViewController(
            district: district,
            dependencyProvider: dependencyProvider
        )
        teamsViewController.delegate = self
        return teamsViewController
    }()
    private lazy var rankingsViewController: DistrictRankingsViewController = {
        let rankingsViewController = DistrictRankingsViewController(
            district: district,
            dependencyProvider: dependencyProvider
        )
        rankingsViewController.delegate = self
        return rankingsViewController
    }()

    // MARK: - Init

    init(district: District, dependencyProvider: DependencyProvider) {
        self.district = district

        super.init(dependencyProvider: dependencyProvider)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitle = "\(district.year) \(district.name) Districts"

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)
    }

    // MARK: Container Data Source

    override var numberOfContainedViewControllers: Int {
        return DistrictView.allCases.count
    }

    override func titleForSegment(at index: Int) -> String? {
        let view = DistrictView(rawValue: index)
        switch view {
        case .events:
            return "Events"
        case .teams:
            return "Teams"
        case .rankings:
            return "Rankings"
        default:
            return nil
        }
    }

    override func viewControllerForSegment(at index: Int) -> UIViewController {
        guard let view = DistrictView(rawValue: index) else {
            fatalError("Unable to setup District views")
        }
        switch view {
        case .events:
            return eventsViewController
        case .teams:
            return teamsViewController
        case .rankings:
            return rankingsViewController
        }
    }
}

extension DistrictViewController: EventsViewControllerDelegate {
    func eventSelected(_ event: Event) {
        /*
        let eventViewController = EventViewController(event: event, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(eventViewController, animated: true)
        */
    }
}

extension DistrictViewController: TeamsViewControllerDelegate {
    func teamSelected(_ team: Team) {
        // TODO: Push
    }
}

extension DistrictViewController: DistrictRankingsViewControllerDelegate {
    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        /*
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
        */
    }
}
