import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit
import TBAUtils

class TeamAtDistrictViewController: ContainerViewController {

    private let teamKey: String
    private let districtKey: String
    private let year: Int
    private var ranking: DistrictRanking

    // MARK: Init

    init(ranking: DistrictRanking, district: District, year: Int, dependencies: Dependencies) {
        self.ranking = ranking
        self.teamKey = ranking.teamKey
        self.districtKey = district.key
        self.year = year

        let summaryViewController = DistrictTeamSummaryViewController(
            ranking: ranking,
            districtKey: district.key,
            dependencies: dependencies
        )
        let breakdownViewController = DistrictBreakdownViewController(
            ranking: ranking,
            districtKey: district.key,
            dependencies: dependencies
        )

        let teamNumber = ranking.teamKey.trimPrefix
        super.init(
            viewControllers: [summaryViewController, breakdownViewController],
            navigationTitle: "Team \(teamNumber)",
            navigationSubtitle: "@ \(year) \(district.abbreviation.uppercased())",
            segmentedControlTitles: ["Summary", "Breakdown"],
            dependencies: dependencies
        )

        rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage.teamIcon,
                primaryAction: UIAction { [weak self] _ in self?.pushTeam() }
            )
        ].compactMap({ $0 })

        summaryViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Team@District: District \(districtKey) | Team \(teamKey)")
    }

    // MARK: - Private Methods

    private func pushTeam() {
        let vc = TeamViewController(teamKey: teamKey, year: year, dependencies: dependencies)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension TeamAtDistrictViewController: DistrictTeamSummaryViewControllerDelegate {

    func eventPointsSelected(eventKey: EventKey) {
        let teamAtEventViewController = TeamAtEventViewController(
            teamKey: teamKey,
            eventKey: eventKey,
            dependencies: dependencies
        )
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
