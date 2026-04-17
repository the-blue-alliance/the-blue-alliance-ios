import Agrume
import MyTBAKit
import Photos
import TBAAPI
import UIKit

class TeamViewController: HeaderContainerViewController {

    private let teamKey: String

    private var team: Team?
    private var yearsParticipated: [Int] = []
    private var avatarImage: UIImage?

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
            avatarImage = nil
            updateInterface()
            if let year { loadAvatar(year: year) }
        }
    }

    // MARK: Init

    convenience init(teamKey: String, nickname: String? = nil, dependencies: Dependencies) {
        self.init(teamKey: teamKey, team: nil, partialNickname: nickname, dependencies: dependencies)
    }

    convenience init(team: Team, dependencies: Dependencies) {
        self.init(teamKey: team.key, team: team, partialNickname: nil, dependencies: dependencies)
    }

    private init(teamKey: String, team: Team?, partialNickname: String?, dependencies: Dependencies) {
        self.teamKey = teamKey
        self.team = team

        let teamNumber = team?.teamNumber ?? Int(TeamKey.trimFRCPrefix(teamKey)) ?? 0
        let nickname: String? = {
            if let team, !team.nickname.isEmpty { return team.nickname }
            return partialNickname
        }()
        let teamNumberNickname = team?.teamNumberNickname ?? "Team \(teamNumber)"

        self.teamHeaderView = TeamHeaderView(TeamHeaderViewModel(teamNumber: teamNumber,
                                                                 avatar: nil,
                                                                 nickname: nickname,
                                                                 teamNumberNickname: teamNumberNickname,
                                                                 year: nil))

        if let team {
            infoViewController = TeamInfoViewController(team: team, dependencies: dependencies)
        } else {
            infoViewController = TeamInfoViewController(teamKey: teamKey, dependencies: dependencies)
        }
        eventsViewController = TeamEventsViewController(teamKey: teamKey, year: nil, dependencies: dependencies)
        mediaViewController = TeamMediaCollectionViewController(teamKey: teamKey, year: Calendar.current.component(.year, from: Date()), dependencies: dependencies)

        super.init(
            viewControllers: [infoViewController, eventsViewController, mediaViewController],
            navigationTitle: teamNumberNickname,
            navigationSubtitle: "----",
            segmentedControlTitles: ["Info", "Events", "Media"],
            dependencies: dependencies
        )

        eventsViewController.delegate = self
        mediaViewController.delegate = self

        teamHeaderView.yearButton.addAction(UIAction { [weak self] _ in
            self?.showSelectYear()
        }, for: .touchUpInside)
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

            // Await in reverse declaration order so async let child tasks are torn
            // down LIFO; otherwise swift_task_dealloc traps. Workaround for a Swift
            // 6.1 codegen bug — remove once Swift 6.3 is our minimum.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
            let years = try? await yearsTask
            let team = (try? await teamTask) ?? nil

            if let team {
                self.team = team
                self.navigationTitle = team.teamNumberNickname
                updateInterface()
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
                                                           avatar: avatarImage,
                                                           nickname: team.nickname.isEmpty ? nil : team.nickname,
                                                           teamNumberNickname: team.teamNumberNickname,
                                                           year: year)
        }
        navigationSubtitle = year?.description ?? "----"
    }

    private func loadAvatar(year: Int) {
        Task { @MainActor in
            guard let media = try? await dependencies.api.teamMediaByYear(teamKey: teamKey, year: year) else { return }
            guard self.year == year else { return }
            let avatar = media.first(where: { $0._type == .avatar })
            avatarImage = Self.decodeAvatar(from: avatar)
            updateInterface()
        }
    }

    private static func decodeAvatar(from media: Media?) -> UIImage? {
        guard let base64 = media?.details?.additionalProperties.value["base64Image"] as? String,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    private func showSelectYear() {
        guard !yearsParticipated.isEmpty else { return }

        let selectTableViewController = SelectTableViewController<TeamViewController>(current: year, options: yearsParticipated, dependencies: dependencies)
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
            self?.navigationController?.dismiss(animated: true)
        })

        navigationController?.present(nav, animated: true)
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
