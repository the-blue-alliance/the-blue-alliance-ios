import Agrume
import MyTBAKit
import Photos
import TBAAPI
import UIKit

enum TeamState {
    case key(String)
    case team(Team)

    var key: String {
        switch self {
        case .key(let key): return key
        case .team(let team): return team.key
        }
    }

    var team: Team? {
        switch self {
        case .key: return nil
        case .team(let team): return team
        }
    }
}

class TeamViewController: HeaderContainerViewController {

    private var state: TeamState
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
        TeamSubscribable(modelKey: state.key)
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

    convenience init(teamKey: TeamKey, nickname: String? = nil, dependencies: Dependencies) {
        // B teams (e.g. "frc5940B") alias their parent team — there's no
        // /team/<N>B page, so route every caller to the canonical key.
        self.init(
            state: .key(teamKey.parentKey),
            partialNickname: nickname,
            dependencies: dependencies
        )
    }

    convenience init(team: Team, dependencies: Dependencies) {
        self.init(state: .team(team), partialNickname: nil, dependencies: dependencies)
    }

    private init(state: TeamState, partialNickname: String?, dependencies: Dependencies) {
        self.state = state

        let teamNumber = state.team?.teamNumber ?? state.key.teamNumber ?? 0
        let nickname: String? = {
            if let team = state.team, !team.nickname.isEmpty { return team.nickname }
            return partialNickname
        }()
        let teamNumberNickname = state.team?.teamNumberNickname ?? "Team \(teamNumber)"

        self.teamHeaderView = TeamHeaderView(
            TeamHeaderViewModel(
                teamNumber: teamNumber,
                avatar: nil,
                nickname: nickname,
                teamNumberNickname: teamNumberNickname,
                year: nil
            )
        )

        switch state {
        case .key(let teamKey):
            infoViewController = TeamInfoViewController(
                teamKey: teamKey,
                dependencies: dependencies
            )
        case .team(let team):
            infoViewController = TeamInfoViewController(team: team, dependencies: dependencies)
        }
        eventsViewController = TeamEventsViewController(
            teamKey: state.key,
            year: nil,
            dependencies: dependencies
        )
        mediaViewController = TeamMediaCollectionViewController(
            teamKey: state.key,
            year: Calendar.current.component(.year, from: Date()),
            dependencies: dependencies
        )

        super.init(
            viewControllers: [infoViewController, eventsViewController, mediaViewController],
            navigationTitle: teamNumberNickname,
            navigationSubtitle: "----",
            segmentedControlTitles: ["Info", "Events", "Media"],
            dependencies: dependencies
        )

        eventsViewController.delegate = self
        mediaViewController.delegate = self

        teamHeaderView.yearButton.addAction(
            UIAction { [weak self] _ in
                self?.showSelectYear()
            },
            for: .touchUpInside
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        loadTeamData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Team: \(state.key)")
    }

    // MARK: - Private

    private func loadTeamData() {
        Task { @MainActor in
            // Unstructured Task handles instead of `async let`: Swift 6.1's
            // async-let stack allocator trips swift_task_dealloc's LIFO check
            // here even with reverse-order awaits (#995 didn't fully fix it).
            // Task handles heap-allocate and sidestep the allocator entirely.
            // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
            let teamHandle = Task { try? await self.dependencies.api.team(key: self.state.key) }
            let yearsHandle = Task {
                try? await self.dependencies.api.teamYearsParticipated(key: self.state.key)
            }

            if let team = await teamHandle.value {
                self.state = .team(team)
                self.navigationTitle = team.teamNumberNickname
                updateInterface()
            }
            if let years = await yearsHandle.value {
                self.yearsParticipated = years.sorted().reversed()
                if year == nil {
                    year = Self.latestYear(
                        currentSeason: statusService.currentSeason,
                        years: yearsParticipated
                    )
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
        if let team = state.team {
            teamHeaderView.viewModel = TeamHeaderViewModel(
                teamNumber: team.teamNumber,
                avatar: avatarImage,
                nickname: team.nickname.isEmpty ? nil : team.nickname,
                teamNumberNickname: team.teamNumberNickname,
                year: year
            )
        }
        navigationSubtitle = year?.description ?? "----"
    }

    private func loadAvatar(year: Int) {
        Task { @MainActor in
            guard
                let media = try? await dependencies.api.teamMediaByYear(
                    teamKey: state.key,
                    year: year
                )
            else { return }
            guard self.year == year else { return }
            let avatar = media.first(where: { $0._type == .avatar })
            avatarImage = Self.decodeAvatar(from: avatar)
            updateInterface()
        }
    }

    private static func decodeAvatar(from media: Media?) -> UIImage? {
        guard case let .case2(payload) = media?.details,
            let data = Data(base64Encoded: payload.base64Image)
        else { return nil }
        return UIImage(data: data)
    }

    private func showSelectYear() {
        guard !yearsParticipated.isEmpty else { return }

        let selectTableViewController = SelectTableViewController<TeamViewController>(
            current: year,
            options: yearsParticipated,
            dependencies: dependencies
        )
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            }
        )

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
        let teamAtEventViewController = TeamAtEventViewController(
            teamKey: state.key,
            eventKey: event.key,
            year: event.year,
            dependencies: dependencies
        )
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
