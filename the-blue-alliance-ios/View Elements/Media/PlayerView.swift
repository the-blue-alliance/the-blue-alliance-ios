import AVKit
import Foundation
import PureLayout
import UIKit
import XCDYouTubeKit

class PlayerView: UIView {

    public var playable: Playable {
        didSet {
            configureView()
        }
    }

    lazy var playerViewController: TBAPlayerViewController = {
        let playerViewController = TBAPlayerViewController()
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        playerViewController.showsPlaybackControls = false
        playerViewController.delegate = self
        return playerViewController
    }()

    fileprivate var loadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    lazy var noDataViewController: NoDataViewController = {
        let noDataViewController = NoDataViewController()
        noDataViewController.textLabel.textColor = UIColor.systemGray6
        return noDataViewController
    }()

    private var youtubeVideoOperation: XCDYouTubeOperation?

    init(playable: Playable) {
        self.playable = playable

        super.init(frame: .zero)
        backgroundColor = UIColor.systemGray6
        configureView()
    }

    deinit {
        youtubeVideoOperation?.cancel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        if playerViewController.view.superview == nil {
            addSubview(playerViewController.view)
            playerViewController.view.autoPinEdgesToSuperviewEdges()
        }

        if loadingActivityIndicator.superview == nil {
            addSubview(loadingActivityIndicator)
            loadingActivityIndicator.autoCenterInSuperview()
            loadingActivityIndicator.startAnimating()
        }

        guard youtubeVideoOperation == nil else {
            return
        }

        if let youtubeKey = playable.youtubeKey {
            youtubeVideoOperation = XCDYouTubeClient.default().getVideoWithIdentifier(youtubeKey) { [weak self] (video, error) in
                self?.youtubeVideoOperation = nil
                guard let streamURLs = video?.streamURLs else {
                    self?.showErrorView(error: "No URLs for video.")
                    return
                }
                guard let streamURL = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)] ?? streamURLs[NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)] ?? streamURLs[NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)] else {
                    self?.showErrorView(error: "Unable to load video URL.")
                    return
                }
                self?.playerViewController.player = AVPlayer(url: streamURL)
                self?.playerViewController.showsPlaybackControls = true
                self?.loadingActivityIndicator.stopAnimating()
            }
        } else {
            // TODO: Handle other video types, yeah?
            showErrorView(error: "No YouTube key for video.")
        }
    }

    private func showErrorView(error: String) {
        playerViewController.player = nil
        playerViewController.showsPlaybackControls = false
        loadingActivityIndicator.stopAnimating()

        noDataViewController.textLabel.text = error
        if noDataViewController.view.superview == nil {
            addSubview(noDataViewController.view)
            noDataViewController.view.autoPinEdgesToSuperviewEdges()
        }
    }

}

extension PlayerView: AVPlayerViewControllerDelegate {

    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        DispatchQueue.main.async {
            self.showErrorView(error: error.localizedDescription)
        }
    }

}

class TBAPlayerViewController: AVPlayerViewController {

    override var prefersStatusBarHidden: Bool {
        return false
    }

}
