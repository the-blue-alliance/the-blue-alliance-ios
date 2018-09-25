import Foundation
import CoreData
import UIKit

class TeamAtDistrictViewController: ContainerViewController {

    private let ranking: DistrictRanking

    private var summaryViewController: DistrictTeamSummaryViewController!
    private var breakdownViewController: DistrictBreakdownViewController!

    override var viewControllers: [Refreshable & Stateful] {
        return [summaryViewController, breakdownViewController]
    }

    // MARK: Init

    init(ranking: DistrictRanking, persistentContainer: NSPersistentContainer) {
        self.ranking = ranking

        super.init(segmentedControlTitles: ["Summary", "Breakdown"],
                   persistentContainer: persistentContainer)

        summaryViewController = DistrictTeamSummaryViewController(ranking: ranking, delegate: self, persistentContainer: persistentContainer)
        breakdownViewController = DistrictBreakdownViewController(ranking: ranking, persistentContainer: persistentContainer)
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

extension TeamAtDistrictViewController: DistrictTeamSummaryViewControllerDelegate {

    func eventPointsSelected(_ eventPoints: DistrictEventPoints) {
        // TODO: Let's see what we can to do not force-unwrap these from Core Data
        let teamAtEventViewController = TeamAtEventViewController(team: eventPoints.team!, event: eventPoints.event!, persistentContainer: persistentContainer)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
