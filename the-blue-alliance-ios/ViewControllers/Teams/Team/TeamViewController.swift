import Agrume
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class TeamViewController: HeaderContainerViewController {

    private let teamKey: String

    // Loaded from TBAAPI after init. Nil until the async load completes.
    private var team: Team?
    private var yearsParticipated: [Int] = []

    private let teamHeaderView: TeamHeaderView

    override var headerView: UIView {
        return teamHeaderView
    }

    private(set) var infoViewController: TeamInfoViewController
    private(set) var eventsViewController: TeamEventsViewController
    private(set) var mediaViewController: TeamMediaCollectionViewController

    override var subscribableModel: MyTBASubscribable {
        TeamSubscribable(modelKey: teamKey)
    }

    private var year: Int? {
        didSet {
            if oldValue == year { return }
            eventsViewController.year = year
            mediaViewController.year = year ?? Calendar.current.component(.year, from: Date())
            updateInterface()
        }
    }

    // MARK: Init

    init(teamKey: String, dependencies: Dependencies) {
        self.teamKey = teamKey

        // Header starts empty; it's populated once the team struct loads.
        self.teamHeaderView = TeamHeaderView(TeamHeaderViewModel(teamNumber: Int(TeamKey.trimFRCPrefix(teamKey)) ?? 0,
                                                                 avatar: nil,
                                                                 nickname: nil,
                                                                 teamNumberNickname: "Team \(TeamKey.trimFRCPrefix(teamKey))",
                                                                 year: nil))

        infoViewController = TeamInfoViewController(teamKey: teamKey, dependencies: dependencies)
        eventsViewController = TeamEventsViewController(teamKey: teamKey, year: nil, dependencies: dependencies)
        mediaViewController = TeamMediaCollectionViewController(teamKey: teamKey, year: Calendar.current.component(.year, from: Date()), dependencies: dependencies)

        super.init(
            viewControllers: [infoViewController, eventsViewController, mediaViewController],
            navigationTitle: "Team \(TeamKey.trimFRCPrefix(teamKey))",
            navigationSubtitle: "----",
            segmentedControlTitles: ["Info", "Events", "Media"],
            
            
            dependencies: dependencies
        )

        eventsViewController.delegate = self
        mediaViewController.delegate = self

        teamHeaderView.yearButton.addTarget(self, action: #selector(showSelectYear), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        loadTeamData()
    }

    // MARK: - Private

    private func loadTeamData() {
        Task { @MainActor in
            async let teamTask = dependencies.api.team(key: teamKey)
            async let yearsTask = dependencies.api.teamYearsParticipated(key: teamKey)

            // Await in reverse declaration order so async let child tasks are
            // torn down LIFO — otherwise swift_task_dealloc traps.
            let years = try? await yearsTask
            let team = (try? await teamTask) ?? nil

            if let team {
                self.team = team
                self.navigationTitle = team.teamNumberNickname
                self.infoViewController.apply(team: team)
            }
            if let years {
                self.yearsParticipated = years.sorted().reversed()
                if year == nil {
                    year = Self.latestYear(currentSeason: statusService.currentSeason, years: yearsParticipated)
                }
            }
        }
    }

    private static func latestYear(currentSeason: Int, years: [Int]) -> Int? {
        guard !years.isEmpty else { return nil }
        let latestYear = years.first!
        if latestYear > currentSeason, years.count > 1 {
            // Find the next year before the current season
            return years.first(where: { $0 <= currentSeason })
        }
        return years.first
    }

    private func updateInterface() {
        if let team {
            teamHeaderView.viewModel = TeamHeaderViewModel(teamNumber: team.teamNumber,
                                                           avatar: nil,
                                                           nickname: team.nickname.isEmpty ? nil : team.nickname,
                                                           teamNumberNickname: team.teamNumberNickname,
                                                           year: year)
        }
        navigationSubtitle = year?.description ?? "----"
    }

    @objc private func showSelectYear() {
        guard !yearsParticipated.isEmpty else { return }

        let selectTableViewController = SelectTableViewController<TeamViewController>(current: year, options: yearsParticipated, dependencies: dependencies)
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelectYear))

        navigationController?.present(nav, animated: true, completion: nil)
    }

    @objc private func dismissSelectYear() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}

private struct TeamSubscribable: MyTBASubscribable {
    let modelKey: String
    var modelType: MyTBAModelType { .team }
    static var notificationTypes: [NotificationType] {
        [.upcomingMatch, .matchScore, .allianceSelection, .awards, .mediaPosted]
    }
}

extension TeamViewController: SelectTableViewControllerDelegate {

    typealias OptionType = Int

    func optionSelected(_ option: Int) {
        year = option
    }

    func titleForOption(_ option: Int) -> String {
        return String(option)
    }

}

extension TeamViewController: EventsListViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, eventKey: event.key, year: event.year, dependencies: dependencies)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }
}

extension TeamViewController: MediaViewer, TeamMediaCollectionViewControllerDelegate {

    func mediaSelected(image: UIImage?, directURL: URL?) {
        show(image: image, directURL: directURL)
    }

}

protocol MediaViewer: UIViewController {}
extension MediaViewer {

    func show(image: UIImage?, directURL: URL?) {
        if let image {
            let agrume = Agrume(image: image)
            agrume.show(from: self)
        } else if let directURL {
            let agrume = Agrume(url: directURL)
            agrume.show(from: self)
        }
    }

}
