import CoreData
import Firebase
import Foundation
import MyTBAKit
import Photos
import TBAAPI
import TBAData
import TBAKit
import UIKit

class TeamAtEventViewController: ContainerViewController {

    let teamKey: String
    let eventKey: String

    let myTBA: MyTBA
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let statusService: StatusService
    let urlOpener: URLOpener
    var matchesViewController: MatchesViewController

    private let summaryViewController: TeamSummaryViewController
    private let statsViewController: TeamStatsViewController
    private let awardsViewController: EventAwardsViewController
    private let mediaViewController: TeamMediaCollectionViewController

    // MARK: - Init

    init(teamKey: String, eventKey: String, year: Int, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.teamKey = teamKey
        self.eventKey = eventKey
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        summaryViewController = TeamSummaryViewController(teamKey: teamKey, eventKey: eventKey, dependencies: dependencies)
        matchesViewController = MatchesViewController(eventKey: eventKey, teamKey: teamKey, myTBA: myTBA, dependencies: dependencies)
        // TeamMediaCollectionViewController is still on managed Team (Phase 3c).
        let managedTeam = Team.insert(teamKey, in: dependencies.persistentContainer.viewContext)
        mediaViewController = TeamMediaCollectionViewController(team: managedTeam, year: year, pasteboard: pasteboard, photoLibrary: photoLibrary, urlOpener: urlOpener, dependencies: dependencies)
        statsViewController = TeamStatsViewController(teamKey: teamKey, eventKey: eventKey, dependencies: dependencies)
        awardsViewController = EventAwardsViewController(eventKey: eventKey, teamKey: teamKey, dependencies: dependencies)

        super.init(viewControllers: [summaryViewController, matchesViewController, mediaViewController, statsViewController, awardsViewController],
                   navigationTitle: "Team \(TeamKey.trimFRCPrefix(teamKey))",
                   navigationSubtitle: nil,
                   segmentedControlTitles: ["Summary", "Matches", "Media", "Stats", "Awards"],
                   dependencies: dependencies)

        rightBarButtonItems = [
            UIBarButtonItem(image: UIImage.eventIcon, style: .plain, target: self, action: #selector(pushEvent))
        ]

        summaryViewController.delegate = self
        matchesViewController.delegate = self
        mediaViewController.delegate = self
        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        Task { @MainActor in
            async let eventTask = try? await dependencies.api.event(key: eventKey)
            async let teamTask = try? await dependencies.api.team(key: teamKey)
            let (event, team) = await (eventTask, teamTask)

            if let team = team ?? nil {
                self.navigationTitle = team.teamNumberNickname
            }
            if let event = event ?? nil {
                self.navigationSubtitle = "@ \(event.friendlyNameWithYear)"
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Team@Event: Event %@ | Team %@", [eventKey, teamKey])
    }

    // MARK: - Private Methods

    @objc private func pushEvent() {
        let eventViewController = EventViewController(eventKey: eventKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    private func pushTeamAtEvent(teamKey: String, eventKey: String, year: Int) {
        let vc = TeamAtEventViewController(teamKey: teamKey, eventKey: eventKey, year: year, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushTeam(teamKey: String) {
        let vc = TeamViewController(teamKey: teamKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushMatch(matchKey: String) {
        let matchViewController = MatchViewController(matchKey: matchKey, teamKey: teamKey, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable, TeamSummaryViewControllerDelegate {

    func teamInfoSelected(teamKey: String) {
        pushTeam(teamKey: teamKey)
    }

    func matchSelected(matchKey: String) {
        pushMatch(matchKey: matchKey)
    }

}

extension TeamAtEventViewController: MediaViewer, TeamMediaCollectionViewControllerDelegate {

    func mediaSelected(_ media: TeamMedia) {
        show(media: media)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        // Don't push to team@event for the team we're already showing team@event for
        if self.teamKey == team.key {
            return
        }
        guard let year = Int(eventKey.prefix(4)) else { return }
        pushTeamAtEvent(teamKey: team.key, eventKey: eventKey, year: year)
    }

}
