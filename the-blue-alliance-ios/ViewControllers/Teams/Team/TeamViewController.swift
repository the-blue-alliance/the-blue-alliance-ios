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

    // Avatars were introduced into FRC in 2018. Pre-2018 years never have
    // avatar media, so we skip the API roundtrip + skeleton entirely and
    // just collapse the avatar slot.
    private static let firstAvatarYear = 2018

    private var _year: Int?
    private var year: Int? {
        get { _year }
        set {
            guard _year != newValue else { return }
            _year = newValue
            propagateYear()
            animateAvatarForYearChange()
        }
    }

    private func propagateYear() {
        eventsViewController.year = year
        mediaViewController.year = year
        updateInterface()
    }

    private func animateAvatarForYearChange() {
        guard let year else { return }

        if year < Self.firstAvatarYear {
            // Pre-avatar era: no fetch, no skeleton, no animation. Just
            // nil out + hard-hide the slot.
            avatarImage = nil
            teamHeaderView.setAvatar(nil)
            return
        }

        if avatarImage != nil {
            // Had an avatar — show skeleton, fetch, reveal result. The
            // skeleton hide animates collapse-and-fade if the new year
            // turns out to have no avatar, in sync with the skeleton out.
            teamHeaderView.showAvatarSkeleton()
            Task { @MainActor in
                await loadAvatar(year: year)
                guard self.year == year else { return }
                teamHeaderView.hideAvatarSkeleton(revealing: avatarImage)
            }
        } else {
            // No prior avatar — silent off-screen fetch, no skeleton.
            // Only animate the avatar in if we actually got one.
            Task { @MainActor in
                await loadAvatar(year: year)
                guard self.year == year else { return }
                if avatarImage != nil {
                    teamHeaderView.transitionAvatar(to: avatarImage)
                }
            }
        }
    }

    // MARK: Init

    convenience init(
        teamKey: TeamKey,
        nickname: String? = nil,
        year: Int? = nil,
        dependencies: Dependencies
    ) {
        // B teams (e.g. "frc5940B") alias their parent team — there's no
        // /team/<N>B page, so route every caller to the canonical key.
        self.init(
            state: .key(teamKey.parentKey),
            partialNickname: nickname,
            year: year,
            dependencies: dependencies
        )
    }

    convenience init(team: Team, year: Int? = nil, dependencies: Dependencies) {
        self.init(
            state: .team(team),
            partialNickname: nil,
            year: year,
            dependencies: dependencies
        )
    }

    // TBA returns the literal "Team <N>" as a fallback nickname for teams
    // without a real one (e.g. team 18). The header view already shows the
    // team number on its own line, so echoing "Team N" as the subtitle
    // duplicates it. Treat the fallback as no nickname here — list-style
    // cells (TeamCell etc.) keep using the raw value, this only affects the
    // header subtitle.
    private static func displayNickname(
        _ raw: String?,
        teamNumber: Int
    ) -> String? {
        guard let raw, !raw.isEmpty else { return nil }
        if raw == "Team \(teamNumber)" { return nil }
        return raw
    }

    private init(
        state: TeamState,
        partialNickname: String?,
        year: Int?,
        dependencies: Dependencies
    ) {
        self.state = state
        self._year = year

        let teamNumber = state.team?.teamNumber ?? state.key.teamNumber ?? 0
        let nickname: String? = {
            let raw: String? = {
                if let team = state.team, !team.nickname.isEmpty { return team.nickname }
                return partialNickname
            }()
            return Self.displayNickname(raw, teamNumber: teamNumber)
        }()
        let teamNumberNickname = state.team?.teamNumberNickname ?? "Team \(teamNumber)"

        self.teamHeaderView = TeamHeaderView(
            TeamHeaderViewModel(
                teamNumber: teamNumber,
                avatar: nil,
                nickname: nickname,
                teamNumberNickname: teamNumberNickname,
                year: year
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
            year: year,
            dependencies: dependencies
        )
        mediaViewController = TeamMediaCollectionViewController(
            teamKey: state.key,
            year: year,
            dependencies: dependencies
        )

        super.init(
            viewControllers: [infoViewController, eventsViewController, mediaViewController],
            navigationTitle: teamNumberNickname,
            navigationSubtitle: nil,
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

        teamHeaderView.showLoadingSkeleton()
        if year != nil {
            teamHeaderView.yearButton.isLoading = true
        }
        loadTeamData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let year {
            dependencies.reporter.log("Team: \(state.key) | Year \(year)")
        } else {
            dependencies.reporter.log("Team: \(state.key)")
        }
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

            if let years = await yearsHandle.value {
                self.yearsParticipated = years.sorted().reversed()
            }
            teamHeaderView.yearButton.isLoading = false

            if let team = await teamHandle.value {
                self.state = .team(team)
                self.navigationTitle = team.teamNumberNickname
            }

            // Avatar fetch is awaited inline below so the header reveals
            // once with team + avatar in place. Skip the public setter (which
            // kicks off avatar work as a fire-and-forget Task) and drive the
            // shared propagation directly.
            let initialYear =
                year
                ?? Self.latestYear(
                    currentSeason: statusService.currentSeason,
                    years: yearsParticipated
                )
            _year = initialYear
            propagateYear()

            if let initialYear, initialYear >= Self.firstAvatarYear {
                await loadAvatar(year: initialYear)
            }

            // Update text-based subviews FIRST so they're sized at their final
            // layout under the still-visible skeleton. The avatar is set by
            // hideLoadingSkeleton itself so its slot collapse/expand animates
            // in sync with the skeleton fade-out.
            updateInterface()
            teamHeaderView.layoutIfNeeded()
            teamHeaderView.hideLoadingSkeleton(revealing: avatarImage)
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
                nickname: Self.displayNickname(team.nickname, teamNumber: team.teamNumber),
                teamNumberNickname: team.teamNumberNickname,
                year: year
            )
        }
    }

    private func loadAvatar(year: Int) async {
        let media: [Media]
        do {
            media = try await dependencies.api.teamMediaByYear(
                teamKey: state.key,
                year: year
            )
        } catch {
            // Network/decoding failure: leave any existing avatar in place.
            return
        }
        guard self.year == year else { return }
        let avatar = media.first(where: { $0._type == .avatar })
        avatarImage = Self.decodeAvatar(from: avatar)
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
