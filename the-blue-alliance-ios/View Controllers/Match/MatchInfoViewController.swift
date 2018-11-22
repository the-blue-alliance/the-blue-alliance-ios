import Foundation
import UIKit
import CoreData
import PureLayout

class MatchInfoViewController: TBAViewController, Observable {

    private let match: Match
    private let teamKey: TeamKey?

    // MARK: - UI

    private let teamsLabel: UILabel = {
        let teamsLabel = UILabel(forAutoLayout: ())
        teamsLabel.text = "Teams"
        return teamsLabel
    }()

    private let scoreTitleLabel: UILabel = {
        let scoreTitleLabel = UILabel(forAutoLayout: ())
        scoreTitleLabel.text = "Score"
        return scoreTitleLabel
    }()

    private lazy var infoStackView: UIStackView = {
        let labels = [teamsLabel, scoreTitleLabel]
        for label in labels {
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center
            label.backgroundColor = .backgroundGray
        }
        return UIStackView(arrangedSubviews: labels)
    }()

    private let matchView: MatchView = {
        let matchView = MatchView()
        matchView.matchInfoStackView.isHidden = true
        return matchView
    }()

    private lazy var matchStackView: UIStackView = {
        let matchStackView = UIStackView(arrangedSubviews: [infoStackView, matchView])
        matchStackView.axis = .vertical
        return matchStackView
    }()

    private let timeLabel: UILabel = {
        let timeLabel = UILabel(forAutoLayout: ())
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textAlignment = .center
        timeLabel.backgroundColor = .white
        return timeLabel
    }()

    private let videoStackView: UIStackView = {
        let videoStackView = UIStackView(forAutoLayout: ())
        videoStackView.axis = .vertical
        videoStackView.alignment = .fill
        videoStackView.distribution = .fill
        videoStackView.spacing = 10
        return videoStackView
    }()

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

        contextObserver.observeObject(object: match, state: .updated) { [unowned self] (_, _) in
            DispatchQueue.main.async {
                self.styleInterface()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.addSubview(matchStackView)
        matchStackView.autoMatch(.width, to: .width, of: scrollView, withOffset: -32)
        matchStackView.autoSetDimension(.height, toSize: 90)
        matchStackView.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 8)
        matchStackView.autoPinEdge(.leading, to: .leading, of: scrollView, withOffset: 16)
        matchStackView.autoPinEdge(.trailing, to: .trailing, of: scrollView, withOffset: -16)

        infoStackView.autoMatch(.height, to: .height, of: matchStackView, withMultiplier: (1.0/3.0))
        // Match the 'Score' label with the size of the score
        scoreTitleLabel.autoMatch(.width, to: .width, of: matchView.redScoreLabel)

        scrollView.addSubview(timeLabel)
        for edge in [ALEdge.top, ALEdge.bottom, ALEdge.leading, ALEdge.trailing] {
            timeLabel.autoPinEdge(edge, to: edge, of: matchView)
        }

        scrollView.addSubview(videoStackView)
        videoStackView.autoPinEdge(.top, to: .bottom, of: matchStackView, withOffset: 8)
        videoStackView.autoPinEdge(.leading, to: .leading, of: matchStackView)
        videoStackView.autoPinEdge(.trailing, to: .trailing, of: matchStackView)
        videoStackView.autoPinEdge(toSuperviewEdge: .bottom)

        styleInterface()
    }

    // MARK: Interface Methods

    func styleInterface() {
        // Override our default background color to be white
        view.backgroundColor = .white

        updateMatchView()
        updateMatchVideos()
    }

    func updateMatchView() {
        matchView.resetView()

        let viewModel = MatchViewModel(match: match, teamKey: teamKey)
        matchView.viewModel = viewModel

        if !viewModel.hasScores {
            teamsLabel.isHidden = true
            timeLabel.isHidden = false

            if let timeString = match.timeString {
                timeLabel.text = timeString
            } else {
                timeLabel.text = "No Time Yet"
            }
            scoreTitleLabel.text = "Time"
        } else {
            teamsLabel.isHidden = false
            timeLabel.isHidden = true
            scoreTitleLabel.text = "Score"
        }
    }

    func updateMatchVideos() {
        for view in videoStackView.arrangedSubviews {
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

    override func reloadViewAfterRefresh() {
        // We'll always have a match, so we shouldn't need to show a no data state
    }

}

extension MatchInfoViewController: Refreshable {

    var refreshKey: String? {
        return match.key
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(day: 1)
    }

    var automaticRefreshEndDate: Date? {
        // Automatically refresh the match info until a few days after the match has been played
        // (Mostly looking for new videos)
        return Calendar.current.date(byAdding: DateComponents(day: 7), to: match.event!.endDate!)!
    }

    var isDataSourceEmpty: Bool {
        // TODO: Think about doing a quiet refresh in the background for match videos on initial load...
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/135
        return (match.videos?.count ?? 0) == 0
    }

    @objc func refresh() {
        var request: URLSessionDataTask?
        request = tbaKit.fetchMatch(key: match.key!, { (modelMatch, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh match - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)

                if let modelMatch = modelMatch {
                    // TODO: Match can never be deleted
                    let event = backgroundContext.object(with: self.match.event!.objectID) as! Event
                    event.insert(modelMatch)

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: request!)
                    }
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

}
