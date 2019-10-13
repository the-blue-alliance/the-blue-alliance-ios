import CoreData
import Crashlytics
import Foundation
import PureLayout
import TBAData
import TBAKit
import UIKit

class MatchInfoViewController: TBAViewController, Observable {

    private let match: Match
    private let teamKey: TeamKey?

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

    // MARK: - Observable

    typealias ManagedType = Match
    lazy var contextObserver: CoreDataContextObserver<Match> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: Class Methods

    static func playerView(for matchVideo: MatchVideo) -> PlayerView {
        let playerView = PlayerView(playable: matchVideo)
        playerView.autoConstrainAttribute(.width, to: .height, of: playerView, withMultiplier: (16.0/9.0))
        return playerView
    }

    // MARK: Init

    init(match: Match, teamKey: TeamKey? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.match = match
        self.teamKey = teamKey

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        contextObserver.observeObject(object: match, state: .updated) { [weak self] (_, _) in
            DispatchQueue.main.async {
                self?.updateInterface()
            }
        }
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
        view.backgroundColor = .systemGray6

        updateInterface()

        if let viewModel = matchSummaryView.viewModel {
            if viewModel.hasScores {
                // Match the 'Score' label with the size of the score
                scoreTitleLabel.autoMatch(.width, to: .width, of: matchSummaryView.redScoreLabel)
            } else {
                // Match the 'Time' label to the size of the time
                scoreTitleLabel.autoMatch(.width, to: .width, of: matchSummaryView.timeView)
            }
        }
    }

    func updateInterface() {
        updateMatchSummaryView()
        updateMatchVideos()
    }

    func updateMatchSummaryView() {
        matchSummaryView.resetView()

        let viewModel = MatchViewModel(match: match, teamKey: teamKey)
        matchSummaryView.viewModel = viewModel

        if !viewModel.hasScores {
            scoreTitleLabel.text = "Time"
        } else {
            scoreTitleLabel.text = "Score"
        }
    }

    func updateMatchVideos() {
        for view in videoStackView.arrangedSubviews {
            videoStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard let videos = match.videos?.allObjects as? [MatchVideo] else {
            return
        }

        for video in videos {
            let playerView = MatchInfoViewController.playerView(for: video)
            videoStackView.addArrangedSubview(playerView)
        }
    }

    override func reloadData() {
        // We'll always have a match, so we shouldn't need to show a no data state
    }

}

extension MatchInfoViewController: Refreshable {

    var refreshKey: String? {
        return match.getValue(\Match.key)
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh the match info until a few days after the match has been played
        // (Mostly looking for new videos)
        guard let event = match.getValue(\Match.event) else {
            return nil
        }
        return Calendar.current.date(byAdding: DateComponents(day: 7), to: event.getValue(\Event.endDate!))!
    }

    var isDataSourceEmpty: Bool {
        // TODO: Think about doing a quiet refresh in the background for match videos on initial load...
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/135
        return (match.getValue(\Match.videos)?.count ?? 0) == 0
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: match.key!, { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                switch result {
                case .success(let match):
                    if let match = match {
                        if let event = self.match.getValue(\Match.event) {
                            let event = context.object(with: event.objectID) as! Event
                            event.insert(match)
                        } else {
                            Match.insert(match, in: context)
                        }
                    } else if !notModified {
                        // TODO: Delete match, bump back up navigation stack
                    }
                default:
                    break
                }

            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        })
        addRefreshOperations([operation])
    }

}
