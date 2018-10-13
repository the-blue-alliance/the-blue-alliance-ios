import Foundation
import UIKit
import youtube_ios_player_helper
import PureLayout

class PlayerView: UIView {

    // TODO: Refactor this too...
    public var playable: Playable {
        didSet {
            configureView()
        }
    }

    private var youtubePlayerView: YTPlayerView = {
        let youtubePlayerView = YTPlayerView()
        return youtubePlayerView
    }()

    fileprivate var loadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    init(playable: Playable) {
        self.playable = playable

        super.init(frame: .zero)
        backgroundColor = .white
        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        if youtubePlayerView.superview == nil {
            youtubePlayerView.delegate = self
            addSubview(youtubePlayerView)
            youtubePlayerView.autoPinEdgesToSuperviewEdges()
        }

        if loadingActivityIndicator.superview == nil {
            addSubview(loadingActivityIndicator)
            loadingActivityIndicator.autoCenterInSuperview()
        }

        loadingActivityIndicator.startAnimating()

        if let youtubeKey = playable.youtubeKey {
            youtubePlayerView.load(withVideoId: youtubeKey)
        }
    }

}

extension PlayerView: YTPlayerViewDelegate {

    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        loadingActivityIndicator.stopAnimating()
    }

}
