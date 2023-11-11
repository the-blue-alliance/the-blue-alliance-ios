import CoreData
import Firebase
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class TeamAtEventViewController: ContainerViewController, ContainerTeamPushable {

    let team: Team
    let event: Event
    lazy var contextObserver: CoreDataContextObserver<Event> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    let myTBA: MyTBA
    let pasteboard: UIPasteboard?
    let photoLibrary: PHPhotoLibrary?
    let statusService: StatusService
    let urlOpener: URLOpener
    var matchesViewController: MatchesViewController

    // MARK: - Init

    init(team: Team, event: Event, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.team = team
        self.event = event
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.statusService = statusService
        self.urlOpener = urlOpener

        let summaryViewController = TeamSummaryViewController(team: team, event: event, dependencies: dependencies)
        matchesViewController = MatchesViewController(event: event, team: team, myTBA: myTBA, dependencies: dependencies)
        let mediaViewController = TeamMediaCollectionViewController(team: team, year: event.year, pasteboard: pasteboard, photoLibrary: photoLibrary, urlOpener: urlOpener, dependencies: dependencies)
        let statsViewController = TeamStatsViewController(team: team, event: event, dependencies: dependencies)
        let awardsViewController = EventAwardsViewController(event: event, team: team, dependencies: dependencies)

        super.init(viewControllers: [summaryViewController, matchesViewController, mediaViewController, statsViewController, awardsViewController],
                   navigationTitle: team.teamNumberNickname,
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorRecorder.log("Team@Event: Event %@ | Team %@", [event.key, team.key])

        contextObserver.observeObject(object: event, state: .updated) { [weak self] (event, _) in
            guard let self = self else { return }
            self.navigationSubtitle = "@ \(event.friendlyNameWithYear)"
        }
    }

    // MARK: - Private Methods

    @objc private func pushEvent() {
        let eventViewController = EventViewController(event: event, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, MatchesViewControllerQueryable, TeamSummaryViewControllerDelegate {

    func teamInfoSelected(_ team: Team) {
        pushTeam(team: team)
    }

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: MediaViewer, TeamMediaCollectionViewControllerDelegate {

    func mediaSelected(_ media: TeamMedia) {
        show(media: media)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        // Don't push to team@event for team we're already showing team@event for
        if self.team == team {
            return
        }
        let teamAtEventViewController = TeamAtEventViewController(team: team, event: event, myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
