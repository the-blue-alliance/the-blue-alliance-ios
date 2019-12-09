import CoreData
import Firebase
import Foundation
import MyTBAKit
import TBAData
import TBAKit
import UIKit

class TeamAtDistrictViewController: ContainerViewController, ContainerTeamPushable {

    internal var team: Team {
        return ranking.team!
    }

    var pushTeamBarButtonItem: UIBarButtonItem?
    private(set) var ranking: DistrictRanking
    let statusService: StatusService
    let myTBA: MyTBA
    let urlOpener: URLOpener

    private var summaryViewController: DistrictTeamSummaryViewController!

    // MARK:  - ContainerTeamPushable

    var fetchTeamOperationQueue: OperationQueue = OperationQueue()

    // MARK: Init

    init(ranking: DistrictRanking, myTBA: MyTBA, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.ranking = ranking
        self.myTBA = myTBA
        self.statusService = statusService
        self.urlOpener = urlOpener

        let summaryViewController = DistrictTeamSummaryViewController(ranking: ranking, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let breakdownViewController = DistrictBreakdownViewController(ranking: ranking, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(
            viewControllers: [summaryViewController, breakdownViewController],
            navigationTitle: ranking.team!.fallbackNickname,
            navigationSubtitle: "@ \(ranking.district!.abbreviationWithYear)",
            segmentedControlTitles: ["Summary", "Breakdown"],
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )

        pushTeamBarButtonItem = UIBarButtonItem(image: UIImage.teamIcon, style: .plain, target: self, action: #selector(pushTeam))
        rightBarButtonItems = [pushTeamBarButtonItem].compactMap({ $0 })

        summaryViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("team_at_district", parameters: ["district": ranking.district!.key!, "team": team.key!])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: Move this out in to some shared class with TeamAtEvent
        fetchTeamOperationQueue.cancelAllOperations()
    }

    // MARK: - Private Methods

    @objc private func pushTeam() {
        pushTeam(team: team)
    }

}

extension TeamAtDistrictViewController: DistrictTeamSummaryViewControllerDelegate {

    func eventPointsSelected(_ eventPoints: DistrictEventPoints) {
        guard let event = eventPoints.event else {
            return
        }

        // TODO: Let's see what we can to do not force-unwrap these from Core Data
        let teamAtEventViewController = TeamAtEventViewController(team: eventPoints.team!, event: event, myTBA: myTBA, showDetailEvent: true, showDetailTeam: false, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
