//
//  TBAMatchViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/26/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAMatchViewController.h"
#import "Team.h"
#import "Event.h"
#import "Match.h"
#import "MatchVideo.h"
#import "TBAPlayerView.h"

@interface TBAMatchViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIStackView *redStackView;
@property (nonatomic, strong) IBOutlet UIView *redContainerView;
@property (nonatomic, strong) IBOutlet UILabel *redScoreLabel;

@property (nonatomic, strong) IBOutlet UIStackView *blueStackView;
@property (nonatomic, strong) IBOutlet UIView *blueContainerView;
@property (nonatomic, strong) IBOutlet UILabel *blueScoreLabel;

@property (nonatomic, strong) IBOutlet UILabel *scoreTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) IBOutlet UIStackView *videoStackView;

@end

@implementation TBAMatchViewController

#pragma mark - Class Methods

- (UILabel *)labelForTeam:(Team *)team {
    UILabel *teamLabel = [[UILabel alloc] init];
    teamLabel.text = team.teamNumber.stringValue;
    UIFont *teamLabelFont;
    if (self.team.teamNumber.integerValue == team.teamNumber.integerValue) {
        teamLabelFont = [UIFont systemFontOfSize:14.0f weight:UIFontWeightBold];
    } else {
        teamLabelFont = [UIFont systemFontOfSize:14.0f];
    }
    teamLabel.font = teamLabelFont;
    teamLabel.textAlignment = NSTextAlignmentCenter;
    teamLabel.backgroundColor = [UIColor clearColor];
    return teamLabel;
}

- (TBAPlayerView *)videoViewForMatchVideo:(MatchVideo *)matchVideo {
    TBAPlayerView *videoView = [[TBAPlayerView alloc] init];
    videoView.translatesAutoresizingMaskIntoConstraints = NO;
    videoView.matchVideo = matchVideo;
    
    NSLayoutConstraint *widescreenConstraint = [NSLayoutConstraint constraintWithItem:videoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:videoView attribute:NSLayoutAttributeHeight multiplier:(16.0f/9.0f) constant:0.0f];
    [videoView addConstraints:@[widescreenConstraint]];

    return videoView;
}

#pragma mark - Properities

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.redContainerView.layer.borderColor = [UIColor redColor].CGColor;
    self.blueContainerView.layer.borderColor = [UIColor blueColor].CGColor;
    [self.scrollView addSubview:self.refreshControl];

    __weak typeof(self) weakSelf = self;
    [self registerForChangeNotifications:^(id  _Nonnull changedObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (changedObject == strongSelf.match) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf styleInterface];
            });
        }
    }];
    
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshMatches];
    };
    
    [self styleInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    [self updateMatchView];
    [self updateMatchVideos];
}

- (void)updateMatchVideos {
    for (UIView *view in self.videoStackView.arrangedSubviews) {
        [view removeFromSuperview];
        [self.videoStackView removeArrangedSubview:view];
    }
    
    for (MatchVideo *matchVideo in [self.match.videos allObjects]) {
        // Skip all TBA videos - they're mostly flv's and can't be played in the YTPlayerView or a AVPlayer
        if (matchVideo.videoType.integerValue == MatchVideoTypeTBA) {
            continue;
        }
        [self.videoStackView addArrangedSubview:[self videoViewForMatchVideo:matchVideo]];
    }
}

- (void)updateMatchView {
    for (UIView *view in self.redStackView.arrangedSubviews) {
        if (view == self.redScoreLabel) {
            continue;
        }
        [view removeFromSuperview];
        [self.redStackView removeArrangedSubview:view];
    }
    
    for (Team *team in self.match.redAlliance.reversedOrderedSet) {
        UILabel *teamLabel = [self labelForTeam:team];
        [self.redStackView insertArrangedSubview:teamLabel atIndex:0];
    }
    self.redScoreLabel.text = self.match.redScore.stringValue;
    
    for (UIView *view in self.blueStackView.arrangedSubviews) {
        if (view == self.blueScoreLabel) {
            continue;
        }
        [view removeFromSuperview];
        [self.blueStackView removeArrangedSubview:view];
    }
    
    for (Team *team in self.match.blueAlliance.reversedOrderedSet) {
        UILabel *teamLabel = [self labelForTeam:team];
        [self.blueStackView insertArrangedSubview:teamLabel atIndex:0];
    }
    self.blueScoreLabel.text = self.match.blueScore.stringValue;
    
    if (self.match.blueScore.integerValue < 0 && self.match.redScore.integerValue < 0) {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = [self.match timeString];
        
        self.scoreTitleLabel.text = @"Time";
    } else {
        self.timeLabel.hidden = YES;
        
        self.scoreTitleLabel.text = @"Score";
    }
    
    UIFont *winnerFont = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    UIFont *notWinnerFont = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    
    // Everyone is a winner in 2015 ╮ (. ❛ ᴗ ❛.) ╭
    if (self.match.event.year.integerValue == 2015 && self.match.compLevel.integerValue != CompLevelFinal) {
        self.redContainerView.layer.borderWidth = 0.0f;
        self.blueContainerView.layer.borderWidth = 0.0f;
        
        self.redScoreLabel.font = notWinnerFont;
        self.blueScoreLabel.font = notWinnerFont;
    } else if (self.match.redScore > self.match.blueScore) {
        self.redContainerView.layer.borderWidth = 2.0f;
        self.blueContainerView.layer.borderWidth = 0.0f;
        
        self.redScoreLabel.font = winnerFont;
        self.blueScoreLabel.font = notWinnerFont;
    } else if (self.match.blueScore > self.match.redScore) {
        self.blueContainerView.layer.borderWidth = 2.0f;
        self.redContainerView.layer.borderWidth = 0.0f;
        
        self.redScoreLabel.font = notWinnerFont;
        self.blueScoreLabel.font = winnerFont;
    } else {
        self.redContainerView.layer.borderWidth = 0.0f;
        self.blueContainerView.layer.borderWidth = 0.0f;
        
        self.redScoreLabel.font = notWinnerFont;
        self.blueScoreLabel.font = notWinnerFont;
    }
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.match.videos.count == 0;
}

- (void)refreshMatches {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchMatchesForEventKey:self.match.event.key withCompletionBlock:^(NSArray *matches, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload match"];
        }
        
        Event *event = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.match.event.objectID];
        
        [strongSelf.persistenceController performChanges:^{
            [Match insertMatchesWithModelMatches:matches forEvent:event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

@end
