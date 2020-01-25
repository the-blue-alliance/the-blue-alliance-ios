import CoreData
import Firebase
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class TeamAtDistrictViewController: ContainerViewController, ContainerTeamPushable {

    internal var team: Team {
        return ranking.team
    }

    private(set) var ranking: DistrictRanking
    let myTBA: MyTBA
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let remoteConfigService: RemoteConfigService
    private(set) var searchService: SearchService
    let statusService: StatusService
    let urlOpener: URLOpener

    private var summaryViewController: DistrictTeamSummaryViewController!

    // MARK: Init

    init(ranking: DistrictRanking, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, remoteConfigService: RemoteConfigService, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.ranking = ranking
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.remoteConfigService = remoteConfigService
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener

        let summaryViewController = DistrictTeamSummaryViewController(ranking: ranking, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let breakdownViewController = DistrictBreakdownViewController(ranking: ranking, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(
            viewControllers: [summaryViewController, breakdownViewController],
            navigationTitle: ranking.team.teamNumberNickname,
            navigationSubtitle: "@ \(ranking.district.abbreviationWithYear)",
            segmentedControlTitles: ["Summary", "Breakdown"],
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )

        rightBarButtonItems = [
            UIBarButtonItem(image: UIImage.teamIcon, style: .plain, target: self, action: #selector(pushTeam))
        ].compactMap({ $0 })

        summaryViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("team_at_district", parameters: ["district": ranking.district.key, "team": team.key])
    }

    // MARK: - Private Methods

    @objc private func pushTeam() {
        pushTeam(team: team)
    }

}

extension TeamAtDistrictViewController: DistrictTeamSummaryViewControllerDelegate {

    func eventPointsSelected(_ eventPoints: DistrictEventPoints) {
        let teamAtEventViewController = TeamAtEventViewController(team: eventPoints.team, event: eventPoints.event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, remoteConfigService: remoteConfigService, searchService: searchService, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
