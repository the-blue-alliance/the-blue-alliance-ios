import Foundation
import CoreData
import UIKit

class TeamAtDistrictViewController: ContainerViewController {

    let ranking: DistrictRanking

    // MARK: Init

    init(ranking: DistrictRanking, persistentContainer: NSPersistentContainer) {
        self.ranking = ranking

        super.init(segmentedControlTitles: ["Summary", "Breakdown"],
                   persistentContainer: persistentContainer)

        let summaryViewController = DistrictTeamSummaryTableViewController(ranking: ranking, eventPointsSelected: { [unowned self] (eventPoints) in
            // TODO: Let's see what we can to do not force-unwrap these from Core Data
            let teamAtEventViewController = TeamAtEventViewController(team: eventPoints.team!, event: eventPoints.event!, persistentContainer: persistentContainer)
            self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
            }, persistentContainer: persistentContainer)

        let breakdownViewController = DistrictBreakdownTableViewController(ranking: ranking, persistentContainer: persistentContainer)

        viewControllers = [summaryViewController, breakdownViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationTitleLabel.text = "Team \(ranking.team!.teamNumber)"
        navigationDetailLabel.text = "@ \(ranking.district!.abbreviationWithYear)"
    }

}
