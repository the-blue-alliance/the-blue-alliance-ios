import Foundation
import CoreData
import UIKit

class TeamAtDistrictViewController: ContainerViewController {

    private(set) var ranking: DistrictRanking
    private let myTBA: MyTBA

    private var summaryViewController: DistrictTeamSummaryViewController!

    // MARK: Init

    init(ranking: DistrictRanking, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit) {
        self.ranking = ranking
        self.myTBA = myTBA

        let summaryViewController = DistrictTeamSummaryViewController(ranking: ranking, persistentContainer: persistentContainer, tbaKit: tbaKit)
        let breakdownViewController = DistrictBreakdownViewController(ranking: ranking, persistentContainer: persistentContainer, tbaKit: tbaKit)

        super.init(viewControllers: [summaryViewController, breakdownViewController],
                   segmentedControlTitles: ["Summary", "Breakdown"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit)

        navigationTitle = "Team \(ranking.teamKey!.teamNumber)"
        navigationSubtitle = "@ \(ranking.district!.abbreviationWithYear)"

        summaryViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TeamAtDistrictViewController: DistrictTeamSummaryViewControllerDelegate {

    func eventPointsSelected(_ eventPoints: DistrictEventPoints) {
        // TODO: Support Team@Event taking a EventKey
        guard let event = eventPoints.eventKey?.event else {
            return
        }

        // TODO: Let's see what we can to do not force-unwrap these from Core Data
        let teamAtEventViewController = TeamAtEventViewController(teamKey: eventPoints.teamKey!, event: event, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
