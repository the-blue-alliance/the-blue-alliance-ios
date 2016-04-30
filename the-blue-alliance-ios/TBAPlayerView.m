//
//  TBAPlayerView.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAPlayerView.h"
#import "YTPlayerView.h"
#import "MatchVideo.h"
@import AVKit;
@import AVFoundation;

@interface TBAPlayerView () <YTPlayerViewDelegate, AVPlayerViewControllerDelegate>

@property (nonatomic, strong) UIView *playerSubview;

@property (nonatomic, strong) YTPlayerView *youtubePlayerView;

@property (nonatomic, strong) AVPlayerViewController *avPlayerViewController;
//@property (nonatomic, strong) AVPlayerLayer *playerLayer;
//@property (nonatomic, strong) UIView *tbaPlayerView;

@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicator;

@end

@implementation TBAPlayerView

#pragma mark - Properities

- (UIActivityIndicatorView *)loadingActivityIndicator {
    if (!_loadingActivityIndicator) {
        _loadingActivityIndicator = [[UIActivityIndicatorView alloc] init];
    }
    return _loadingActivityIndicator;
}

- (YTPlayerView *)youtubePlayerView {
    if (!_youtubePlayerView) {
        _youtubePlayerView = [[YTPlayerView alloc] init];
        _youtubePlayerView.translatesAutoresizingMaskIntoConstraints = NO;
        _youtubePlayerView.delegate = self;
    }
    return _youtubePlayerView;
}

- (AVPlayerViewController *)avPlayerViewController {
    if (!_avPlayerViewController) {
        _avPlayerViewController = [[AVPlayerViewController alloc] init];
        _avPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        _avPlayerViewController.delegate = self;
    }
    return _avPlayerViewController;
}

- (void)setMatchVideo:(MatchVideo *)matchVideo {
    _matchVideo = matchVideo;
    
    if (self.playerSubview) {
        [self.playerSubview removeFromSuperview];
    }

    self.backgroundColor = [UIColor blueColor];
    
    if (matchVideo.videoType.integerValue == MatchVideoTypeYouTube) {
        self.playerSubview = self.youtubePlayerView;
        if (![self.youtubePlayerView loadWithVideoId:matchVideo.key]) {
            // TODO: Failed to load video
        }
    } else if (matchVideo.videoType.integerValue == MatchVideoTypeTBA) {
        self.playerSubview = self.avPlayerViewController.view;
        NSLog(@"Here: %@", [NSURL URLWithString:matchVideo.key]);
        self.avPlayerViewController.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:matchVideo.key]];
    }
    
    [self addSubview:self.playerSubview];

    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.playerSubview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.playerSubview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.playerSubview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.playerSubview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    [self addConstraints:@[leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]];

}

#pragma mark YTPlayerViewDelegate

// Something in here

@end
