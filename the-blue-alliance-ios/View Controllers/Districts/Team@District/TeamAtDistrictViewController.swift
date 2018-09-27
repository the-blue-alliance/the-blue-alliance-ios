import Foundation
import CoreData
import UIKit

class TeamAtDistrictViewController: ContainerViewController {

    private let ranking: DistrictRanking

    private var summaryViewController: DistrictTeamSummaryViewController!

    // MARK: Init

    init(ranking: DistrictRanking, persistentContainer: NSPersistentContainer) {
        self.ranking = ranking

        let summaryViewController = DistrictTeamSummaryViewController(ranking: ranking, persistentContainer: persistentContainer)
        let breakdownViewController = DistrictBreakdownViewController(ranking: ranking, persistentContainer: persistentContainer)

        super.init(viewControllers: [summaryViewController, breakdownViewController],
                   segmentedControlTitles: ["Summary", "Breakdown"],
                   persistentContainer: persistentContainer)

        summaryViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitle = "Team \(ranking.team!.teamNumber)"
        navigationSubtitle = "@ \(ranking.district!.abbreviationWithYear)"
    }

}

extension TeamAtDistrictViewController: DistrictTeamSummaryViewControllerDelegate {

    func eventPointsSelected(_ eventPoints: DistrictEventPoints) {
        // TODO: Let's see what we can to do not force-unwrap these from Core Data
        let teamAtEventViewController = TeamAtEventViewController(team: eventPoints.team!, event: eventPoints.event!, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
