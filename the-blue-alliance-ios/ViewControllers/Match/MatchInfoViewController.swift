import Foundation
import PureLayout
import TBAAPI
import TBAProtocols
import UIKit

class MatchInfoViewController: TBAViewController, Refreshable {

    private let matchKey: String
    private let teamKey: String?

    private var match: Match?

    // MARK: - UI

    private let teamsLabel: UILabel = {
        let teamsLabel = UILabel(forAutoLayout: ())
        teamsLabel.text = "Teams"
        teamsLabel.translatesAutoresizingMaskIntoConstraints = false
        return teamsLabel
    }()

    private let scoreTitleLabel: UILabel = {
        let scoreTitleLabel = UILabel(forAutoLayout: ())
        scoreTitleLabel.text = "Score"
        scoreTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return scoreTitleLabel
    }()

    private lazy var infoStackView: UIStackView = {
        let labels = [teamsLabel, scoreTitleLabel]
        for label in labels {
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center
            label.backgroundColor = UIColor.systemFill
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        let infoStackView = UIStackView(arrangedSubviews: labels)
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        return infoStackView
    }()

    private let matchSummaryView: MatchSummaryView = {
        let matchSummaryView = MatchSummaryView(teamsTappable: true)
        matchSummaryView.matchInfoStackView.isHidden = true
        matchSummaryView.translatesAutoresizingMaskIntoConstraints = false
        return matchSummaryView
    }()

    private lazy var matchStackView: UIStackView = {
        let matchStackView = UIStackView(arrangedSubviews: [infoStackView, matchSummaryView])
        matchStackView.axis = .vertical
        matchStackView.translatesAutoresizingMaskIntoConstraints = false
        return matchStackView
    }()

    private let videoStackView: UIStackView = {
        let videoStackView = UIStackView(forAutoLayout: ())
        videoStackView.axis = .vertical
        videoStackView.alignment = .fill
        videoStackView.distribution = .fill
        videoStackView.spacing = 10
        videoStackView.translatesAutoresizingMaskIntoConstraints = false
        return videoStackView
    }()

    public var matchSummaryDelegate: MatchSummaryViewDelegate? {
        get {
            return matchSummaryView.delegate
        }
        set {
            matchSummaryView.delegate = newValue
        }
    }

    // MARK: Init

    init(matchKey: String, teamKey: String? = nil, dependencies: Dependencies) {
        self.matchKey = matchKey
        self.teamKey = teamKey

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        styleInterface()
    }

    // MARK: Interface Methods

    func styleInterface() {
        scrollView.addSubview(matchStackView)
        matchStackView.autoSetDimension(.height, toSize: 90)
        matchStackView.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 8)
        matchStackView.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        matchStackView.autoPinEdge(toSuperviewSafeArea: .trailing, withInset: 16)

        infoStackView.autoMatch(.height, to: .height, of: matchStackView, withMultiplier: (1.0/3.0))

        scrollView.addSubview(videoStackView)
        videoStackView.autoPinEdge(.top, to: .bottom, of: matchStackView, withOffset: 8)
        videoStackView.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        videoStackView.autoPinEdge(toSuperviewSafeArea: .trailing, withInset: 16)
        videoStackView.autoPinEdge(toSuperviewEdge: .bottom)

        // Override our default background color to be white
        view.backgroundColor = .systemBackground
    }

    func apply(match: Match) {
        self.match = match
        updateInterface()
    }

    func updateInterface() {
        updateMatchSummaryView()
        updateMatchVideos()
    }

    func updateMatchSummaryView() {
        guard let match else { return }
        matchSummaryView.resetView()

        var baseTeamKeys: [String] = []
        if let teamKey { baseTeamKeys.append(teamKey) }
        let viewModel = MatchViewModel(apiMatch: match, baseTeamKeys: baseTeamKeys)
        matchSummaryView.viewModel = viewModel

        scoreTitleLabel.text = viewModel.hasScores ? "Score" : "Time"
    }

    func updateMatchVideos() {
        for view in videoStackView.arrangedSubviews {
            videoStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard let match else { return }
        for video in match.videos {
            let playerView = Self.playerView(for: video)
            videoStackView.addArrangedSubview(playerView)
        }
    }

    private static func playerView(for video: Match.VideosPayloadPayload) -> PlayerView {
        let playerView = PlayerView(playable: MatchVideoPlayable(video: video))
        playerView.autoConstrainAttribute(.width, to: .height, of: playerView, withMultiplier: (16.0/9.0))
        return playerView
    }

    override func reloadData() {
        // We'll always have a match, so we shouldn't need to show a no data state
    }

    // MARK: - Refreshable

    var isDataSourceEmpty: Bool {
        // Match hasn't loaded yet, or it has loaded but has no videos.
        (match?.videos.count ?? 0) == 0
    }

    @objc func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            if let fetched = try await self.api.match(key: self.matchKey) {
                self.apply(match: fetched)
            }
        }
    }

}

// Bridges the API's `Match.VideosPayloadPayload` to the existing `Playable`
// contract that `PlayerView` consumes. Only YouTube videos are playable —
// the old `MatchVideo.youtubeKey` mapped the same way.
private struct MatchVideoPlayable: Playable {
    let video: Match.VideosPayloadPayload

    var youtubeKey: String? {
        video._type == "youtube" ? video.key : nil
    }
}
