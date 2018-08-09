import Foundation
import UIKit
import CoreData
import TBAKit

class MatchInfoViewController: TBAViewController, Observable {

    public var match: Match!
    public var team: Team?

    let winnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    let notWinnerFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)

    // MARK: - Persistable

    override var persistentContainer: NSPersistentContainer! {
        didSet {
            contextObserver.observeObject(object: match, state: .updated) { [weak self] (_, _) in
                DispatchQueue.main.async {
                    self?.styleInterface()
                }
            }
        }
    }

    // MARK: - Observable

    typealias ManagedType = Match
    lazy var contextObserver: CoreDataContextObserver<Match> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    @IBOutlet var redStackView: UIStackView!
    @IBOutlet var redContainerView: UIView! {
        didSet {
            redContainerView.layer.borderColor = UIColor.red.cgColor
        }
    }
    @IBOutlet var redScoreLabel: UILabel!

    @IBOutlet var blueStackView: UIStackView!
    @IBOutlet var blueContainerView: UIView! {
        didSet {
            blueContainerView.layer.borderColor = UIColor.blue.cgColor
        }
    }
    @IBOutlet var blueScoreLabel: UILabel!

    @IBOutlet var scoreTitleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    @IBOutlet var videoStackView: UIStackView!

    // MARK: Class Methods

    static func playerView(for matchVideo: MatchVideo) -> PlayerView {
        let playerView = PlayerView(playable: matchVideo)

        playerView.autoConstrainAttribute(.width, to: .height, of: playerView, withMultiplier: (16.0/9.0))

        return playerView
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

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
        for view in redStackView.arrangedSubviews {
            if view == redScoreLabel {
                continue
            }
            view.removeFromSuperview()
        }

        if let redAlliance = match.redAlliance?.reversed() as? [Team] {
            for team in redAlliance {
                let teamLabel = MatchTableViewCell.label(for: team, baseTeam: self.team)
                redStackView.insertArrangedSubview(teamLabel, at: 0)
            }
        }
        if let redScore = match.redScore {
            redScoreLabel.text = redScore.stringValue
        }

        for view in blueStackView.arrangedSubviews {
            if view == blueScoreLabel {
                continue
            }
            view.removeFromSuperview()
        }

        if let blueAlliance = match.blueAlliance?.reversed() as? [Team] {
            for team in blueAlliance {
                let teamLabel = MatchTableViewCell.label(for: team, baseTeam: self.team)
                blueStackView.insertArrangedSubview(teamLabel, at: 0)
            }
        }
        if let blueScore = match.blueScore {
            blueScoreLabel.text = blueScore.stringValue
        }

        if match?.blueScore == nil && match?.redScore == nil {
            timeLabel.isHidden = false

            if let timeString = match?.timeString {
                timeLabel.text = timeString
            } else {
                timeLabel.text = "No Time Yet"
            }
            scoreTitleLabel.text = "Time"
        } else {
            timeLabel.isHidden = true
            scoreTitleLabel.text = "Score"
        }

        if let compLevelString = match?.compLevel,
            let compLevel = MatchCompLevel(rawValue: compLevelString),
            match?.event?.year == Int16(2015),
            compLevel != MatchCompLevel.final {
            redContainerView.layer.borderWidth = 0.0
            blueContainerView.layer.borderWidth = 0.0

            redScoreLabel.font = notWinnerFont
            blueScoreLabel.font = notWinnerFont
        } else if match?.winningAlliance == "red" {
            redContainerView.layer.borderWidth = 2.0
            blueContainerView.layer.borderWidth = 0.0

            redScoreLabel.font = winnerFont
            blueScoreLabel.font = notWinnerFont
        } else if match?.winningAlliance == "blue" {
            blueContainerView.layer.borderWidth = 2.0
            redContainerView.layer.borderWidth = 0.0

            redScoreLabel.font = notWinnerFont
            blueScoreLabel.font = winnerFont
        } else {
            redContainerView.layer.borderWidth = 0.0
            blueContainerView.layer.borderWidth = 0.0

            redScoreLabel.font = notWinnerFont
            blueScoreLabel.font = notWinnerFont
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

    // MARK: Refresh

    override func shouldNoDataRefresh() -> Bool {
        // TODO: Think about doing a quiet refresh in the background for match videos on initial load...
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/135
        return (match.videos?.count ?? 0) == 0
    }

    override func refresh() {
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchMatch(key: match.key!, { (modelMatch, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh match - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.match.event!.objectID) as! Event

                if let modelMatch = modelMatch {
                    backgroundEvent.addToMatches(Match.insert(with: modelMatch, for: backgroundEvent, in: backgroundContext))
                }

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func reloadViewAfterRefresh() {
        // We'll always have a match, so we shouldn't need to show a no data state
    }

}
