import AVKit
import Foundation
import PureLayout
import TBAData
import TBAProtocols
import UIKit
import YouTubeiOSPlayerHelper

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
            playerView.load(withVideoId: youtubeKey)
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
