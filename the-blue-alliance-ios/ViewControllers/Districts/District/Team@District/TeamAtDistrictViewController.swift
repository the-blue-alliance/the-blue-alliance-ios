import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class TeamAtDistrictViewController: ContainerViewController {

    private let teamKey: String
    private let districtKey: String
    private let year: Int
    private var ranking: DistrictRanking

    let myTBA: MyTBA
    let myTBAStores: MyTBAStores
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let statusService: StatusService
    let urlOpener: URLOpener

    private var summaryViewController: DistrictTeamSummaryViewController!

    // MARK: Init

    init(ranking: DistrictRanking, district: District, year: Int, myTBA: MyTBA, myTBAStores: MyTBAStores, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.ranking = ranking
        self.teamKey = ranking.teamKey
        self.districtKey = district.key
        self.year = year
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        let summaryViewController = DistrictTeamSummaryViewController(ranking: ranking, districtKey: district.key, dependencies: dependencies)
        let breakdownViewController = DistrictBreakdownViewController(ranking: ranking, districtKey: district.key, dependencies: dependencies)

        let teamNumber = TeamKey.trimFRCPrefix(ranking.teamKey)
        super.init(
            viewControllers: [summaryViewController, breakdownViewController],
            navigationTitle: "Team \(teamNumber)",
            navigationSubtitle: "@ \(year) \(district.abbreviation.uppercased())",
            segmentedControlTitles: ["Summary", "Breakdown"],
            dependencies: dependencies
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

        errorRecorder.log("Team@District: District %@ | Team %@", [districtKey, teamKey])
    }

    // MARK: - Private Methods

    @objc private func pushTeam() {
        let vc = TeamViewController(teamKey: teamKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, myTBAStores: myTBAStores, dependencies: dependencies)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension TeamAtDistrictViewController: DistrictTeamSummaryViewControllerDelegate {

    func eventPointsSelected(eventKey: String) {
        let year = Int(eventKey.prefix(4)) ?? self.year
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: eventKey, year: year, myTBA: myTBA, myTBAStores: myTBAStores, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
