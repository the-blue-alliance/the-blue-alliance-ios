//
//  PlayerView.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import youtube_ios_player_helper
import PureLayout

class PlayerView: UIView {
    
    public var media: Media {
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
    
    init(media: Media) {
        self.media = media
        
        super.init(frame: .zero)
        backgroundColor = .white
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
        
        if media.type! == MediaType.youtubeVideo.rawValue {
            if let key = media.key {
                youtubePlayerView.load(withVideoId: key)
            }
            if let foreignKey = media.foreignKey {
                youtubePlayerView.load(withVideoId: foreignKey)
            }
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
