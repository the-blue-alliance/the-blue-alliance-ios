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

@interface TBAPlayerView () <YTPlayerViewDelegate>

@property (nonatomic, strong) YTPlayerView *youtubePlayerView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicator;

@end

@implementation TBAPlayerView

#pragma mark - Properities

- (UIActivityIndicatorView *)loadingActivityIndicator {
    if (!_loadingActivityIndicator) {
        _loadingActivityIndicator = [[UIActivityIndicatorView alloc] init];
        _loadingActivityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
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

- (void)setMatchVideo:(MatchVideo *)matchVideo {
    _matchVideo = matchVideo;
    
    if (!self.youtubePlayerView.superview) {
        [self addSubview:self.youtubePlayerView];

        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.youtubePlayerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.youtubePlayerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.youtubePlayerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.youtubePlayerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        [self addConstraints:@[leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]];
    }

    if (!self.loadingActivityIndicator.superview) {
        [self addSubview:self.loadingActivityIndicator];
        
        NSLayoutConstraint *centerHorizontallyConstraint = [NSLayoutConstraint constraintWithItem:self.loadingActivityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *centerVerticallyConstraint = [NSLayoutConstraint constraintWithItem:self.loadingActivityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [self addConstraints:@[centerHorizontallyConstraint, centerVerticallyConstraint]];
    }

    [self.loadingActivityIndicator startAnimating];
    if (![self.youtubePlayerView loadWithVideoId:matchVideo.key]) {
        // TODO: Failed to load video
        [self.loadingActivityIndicator stopAnimating];
    }
}

#pragma mark YTPlayerViewDelegate

- (UIView *)playerViewPreferredInitialLoadingView:(YTPlayerView *)playerView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    return view;
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [self.loadingActivityIndicator stopAnimating];
}

@end
