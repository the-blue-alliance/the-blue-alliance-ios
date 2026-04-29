import AVKit
import Foundation
import PureLayout
import UIKit
import YouTubeiOSPlayerHelper

protocol Playable {
    var youtubeKey: String? { get }
}

class PlayerView: UIView {

    private let playerView: YTPlayerView = YTPlayerView(frame: .zero)
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private(set) var loadedKey: String?

    lazy var noDataViewController: NoDataViewController = {
        let noDataViewController = NoDataViewController()
        noDataViewController.view.backgroundColor = UIColor.systemGray6
        return noDataViewController
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.systemGray6

        playerView.configureForAutoLayout()
        playerView.delegate = self
        addSubview(playerView)
        playerView.autoPinEdgesToSuperviewEdges()

        loadingIndicator.configureForAutoLayout()
        addSubview(loadingIndicator)
        loadingIndicator.autoCenterInSuperview()
    }

    convenience init(playable: Playable) {
        self.init()
        load(youtubeKey: playable.youtubeKey)
    }

    deinit {
        playerView.stopVideo()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load(youtubeKey: String?) {
        // Only short-circuit when we already loaded the same non-nil key, so a
        // fresh view (loadedKey == nil) loaded with nil still surfaces the error.
        if let youtubeKey, youtubeKey == loadedKey {
            return
        }
        playerView.stopVideo()
        loadedKey = youtubeKey
        if let youtubeKey {
            removeErrorView()
            loadingIndicator.startAnimating()
            let parsed = YouTubeForeignKey(youtubeKey)
            playerView.load(withVideoId: parsed.videoId, playerVars: parsed.playerVars)
        } else {
            loadingIndicator.stopAnimating()
            showErrorView(error: "No YouTube key for video.")
        }
    }

    func stopVideo() {
        playerView.stopVideo()
        loadingIndicator.stopAnimating()
    }

    private func showErrorView(error: String) {
        noDataViewController.textLabel.text = error
        if noDataViewController.view.superview == nil {
            addSubview(noDataViewController.view)
            noDataViewController.view.autoPinEdgesToSuperviewEdges()
        }
    }

    private func removeErrorView() {
        if noDataViewController.view.superview != nil {
            noDataViewController.view.removeFromSuperview()
        }
    }

}

extension PlayerView: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        loadingIndicator.stopAnimating()
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        loadingIndicator.stopAnimating()
        showErrorView(error: "Unable to load video.")
    }
}

struct YouTubeForeignKey {
    let videoId: String
    let playerVars: [String: Any]

    init(_ raw: String) {
        let parts = raw.split(maxSplits: 1, omittingEmptySubsequences: false) {
            $0 == "?" || $0 == "#"
        }
        videoId = String(parts[0])
        let tail = parts.count == 2 ? parts[1].replacingOccurrences(of: "#", with: "&") : ""
        var vars: [String: Any] = [:]
        // YouTube share URLs use `t=`; the iframe player param is `start`.
        for item in URLComponents(string: "?" + tail)?.queryItems ?? [] {
            vars[item.name == "t" ? "start" : item.name] = item.value ?? ""
        }
        playerVars = vars
    }
}
