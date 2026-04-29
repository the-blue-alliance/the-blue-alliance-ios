import AVKit
import Foundation
import PureLayout
import UIKit
import YouTubeiOSPlayerHelper

protocol Playable {
    var youtubeKey: String? { get }
}

class PlayerView: UIView {

    private let playable: Playable
    private let playerView: YTPlayerView = YTPlayerView(frame: .zero)

    lazy var noDataViewController: NoDataViewController = {
        let noDataViewController = NoDataViewController()
        noDataViewController.view.backgroundColor = UIColor.systemGray6
        return noDataViewController
    }()

    init(playable: Playable) {
        self.playable = playable

        super.init(frame: .zero)
        backgroundColor = UIColor.systemGray6

        playerView.configureForAutoLayout()
        addSubview(playerView)
        playerView.autoPinEdgesToSuperviewEdges()

        if let youtubeKey = playable.youtubeKey {
            let parsed = YouTubeForeignKey(youtubeKey)
            playerView.load(withVideoId: parsed.videoId, playerVars: parsed.playerVars)
        } else {
            showErrorView(error: "No YouTube key for video.")
        }
    }

    deinit {
        playerView.stopVideo()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func showErrorView(error: String) {
        noDataViewController.textLabel.text = error
        if noDataViewController.view.superview == nil {
            addSubview(noDataViewController.view)
            noDataViewController.view.autoPinEdgesToSuperviewEdges()
        }
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
