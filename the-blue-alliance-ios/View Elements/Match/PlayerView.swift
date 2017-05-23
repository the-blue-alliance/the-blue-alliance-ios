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
    
    public var media: Media? {
        didSet {
            configureView()
        }
    }
    
    var youtubePlayerView: YTPlayerView = {
        let youtubePlayerView = YTPlayerView()
        youtubePlayerView.translatesAutoresizingMaskIntoConstraints = false
        return youtubePlayerView
    }()
    
    var loadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    func configureView() {
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
        
        guard let mediaTypeString = media?.type else {
            return
        }
        
        let mediaType = MediaType(rawValue: mediaTypeString)
        if mediaType == MediaType.youtubeVideo {
            if let key = media?.key {
                youtubePlayerView.load(withVideoId: key)
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
