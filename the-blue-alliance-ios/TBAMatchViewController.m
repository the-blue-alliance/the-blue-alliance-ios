//
//  TBAMatchViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/26/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAMatchViewController.h"
#import "YTPlayerView.h"
#import "Team.h"
#import "Event.h"
#import "Match.h"
#import "MatchVideo.h"

@interface TBAMatchViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIStackView *redStackView;
@property (nonatomic, weak) IBOutlet UIView *redContainerView;
@property (nonatomic, weak) IBOutlet UILabel *redScoreLabel;

@property (nonatomic, weak) IBOutlet UIStackView *blueStackView;
@property (nonatomic, weak) IBOutlet UIView *blueContainerView;
@property (nonatomic, weak) IBOutlet UILabel *blueScoreLabel;

@property (nonatomic, weak) IBOutlet UILabel *scoreTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak) IBOutlet UIStackView *videoStackView;

@end

@implementation TBAMatchViewController

#pragma mark - Class Methods

- (UILabel *)labelForTeam:(Team *)team {
    UILabel *teamLabel = [[UILabel alloc] init];
    teamLabel.text = team.teamNumber.stringValue;
    teamLabel.font = [UIFont systemFontOfSize:14.0f];
    teamLabel.textAlignment = NSTextAlignmentCenter;
    teamLabel.backgroundColor = [UIColor clearColor];
    return teamLabel;
}

- (YTPlayerView *)videoViewForMatchVideo:(MatchVideo *)matchVideo {
    YTPlayerView *videoView = [[YTPlayerView alloc] init];
    videoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *widescreenConstraint = [NSLayoutConstraint constraintWithItem:videoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:videoView attribute:NSLayoutAttributeHeight multiplier:(16.0f/9.0f) constant:0.0f];
    [videoView addConstraints:@[widescreenConstraint]];
    
    [videoView loadWithVideoId:matchVideo.key];
    
    return videoView;
}

#pragma mark - Properities

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.redContainerView.layer.borderColor = [UIColor redColor].CGColor;
    self.blueContainerView.layer.borderColor = [UIColor blueColor].CGColor;
    [self.scrollView addSubview:self.refreshControl];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf hideNoDataView];
        [strongSelf refreshMatches];
    };
    
    [self registerForChangeNotifications];
    
    [self updateInterface];
}

#pragma mark - Private Methods

- (void)registerForChangeNotifications {
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:self.persistenceController.managedObjectContext queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSSet *updatedObjects = note.userInfo[NSUpdatedObjectsKey];
        for (NSManagedObject *obj in updatedObjects) {
            if (obj == self.match) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateInterface];
                });
            }
        }
    }];
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.match.videos.count == 0;
}

- (void)refreshMatches {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchMatchesForEventKey:self.match.event.key withCompletionBlock:^(NSArray *matches, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload match"];
        } else {
            Event *event = [strongSelf.persistenceController.backgroundManagedObjectContext objectWithID:strongSelf.match.event.objectID];
            
            [strongSelf.persistenceController performChanges:^{
                [Match insertMatchesWithModelMatches:matches forEvent:event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
            }];
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - Interface Methods

- (void)updateInterface {
    [self updateMatchView];
    [self updateMatchVideos];
}

- (void)updateMatchVideos {
    for (UIView *view in self.videoStackView.arrangedSubviews) {
        [view removeFromSuperview];
        [self.videoStackView removeArrangedSubview:view];
    }

    for (MatchVideo *matchVideo in [self.match.videos allObjects]) {
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

@end
