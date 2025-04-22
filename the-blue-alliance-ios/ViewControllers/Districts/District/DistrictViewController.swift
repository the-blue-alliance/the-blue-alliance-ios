import Firebase
import MyTBAKit
import Photos
import UIKit
import TBAModels

class DistrictViewController: SimpleContainerViewController {

    private let district: District

    private lazy var eventsViewController: DistrictEventsViewController = {
        let eventsViewController = DistrictEventsViewController(district: district, dependencies: dependencies)
        eventsViewController.delegate = self
        return eventsViewController
    }()
    // private(set) var teamsViewController: DistrictTeamsViewController
    private lazy var rankingsViewController: DistrictRankingsViewController = {
        let rankingsViewController = DistrictRankingsViewController(district: district, dependencies: dependencies)
        rankingsViewController.delegate = self
        return rankingsViewController
    }()

    // MARK: - Init

    init(district: District, dependencies: Dependencies) {
        self.district = district

        super.init(dependencies: dependencies)

        dataSource = self
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
}

extension DistrictViewController: ContainerDataSource {

    func numberOfSegments(in containerViewController: SimpleContainerViewController) -> Int {
        // TODO: Should be 3
        return 2
    }

    // TODO: Can we use generics to give this some Section enum?
    func containerViewController(_ containerViewController: SimpleContainerViewController, titleForSegmentAt index: Int) -> String? {
        if index == 0 {
            return "Events"
        }
        return "Rankings"
    }
    
    func containerViewController(_ containerViewController: SimpleContainerViewController, viewControllerForSegmentAt index: Int) -> UIViewController {
        if index == 0 {
            return eventsViewController
        }
        return rankingsViewController
    }
    
}

extension DistrictViewController: SimpleEventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        /*
        let eventViewController = EventViewController(event: event, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(eventViewController, animated: true)
        */
    }

    func title(for event: Event) -> String? {
        return "\(event.weekString) Events"
    }
}

/*
extension DistrictViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        let teamViewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(teamViewController, animated: true)
    }

}
*/

extension DistrictViewController: DistrictRankingsViewControllerDelegate {

    func districtRankingSelected(_ districtRanking: DistrictRanking) {
        /*
        let teamAtDistrictViewController = TeamAtDistrictViewController(ranking: districtRanking, myTBA: myTBA, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtDistrictViewController, animated: true)
        */
    }

}
