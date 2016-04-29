//
//  TBAMatchTableViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMatchTableViewCell.h"
#import "Match.h"
#import "Event.h"
#import "Team.h"

@interface TBAMatchTableViewCell ()

@property (nonatomic, strong) IBOutlet UILabel *matchNumberLabel;

@property (nonatomic, strong) IBOutlet UIStackView *redStackView;
@property (nonatomic, strong) IBOutlet UIView *redContainerView;
@property (nonatomic, strong) IBOutlet UILabel *redScoreLabel;

@property (nonatomic, strong) IBOutlet UIStackView *blueStackView;
@property (nonatomic, strong) IBOutlet UIView *blueContainerView;
@property (nonatomic, strong) IBOutlet UILabel *blueScoreLabel;

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) NSArray<UIView *> *coloredViews;

@end

@implementation TBAMatchTableViewCell

#pragma mark - Properities

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    NSArray<UIColor *> *colors = [self storeBaseColorsForView:self.coloredViews];
    [super setSelected:selected animated:animated];
    
    if (selected){
        [self restoreBaseColors:colors forViews:self.coloredViews];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    NSArray<UIColor *> *colors = [self storeBaseColorsForView:self.coloredViews];
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted){
        [self restoreBaseColors:colors forViews:self.coloredViews];
    }
}

- (NSArray<UIView *> *)coloredViews {
    return @[self.redContainerView, self.redScoreLabel, self.blueContainerView, self.blueScoreLabel, self.timeLabel];
}

- (void)setMatch:(Match *)match {
    _match = match;
    
    self.matchNumberLabel.text = [match friendlyMatchName];
    
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
    
    if (match.blueScore.integerValue < 0 && match.redScore.integerValue < 0) {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = [match timeString];
    } else {
        self.timeLabel.hidden = YES;
    }
    
    UIFont *winnerFont = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    UIFont *notWinnerFont = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    
    // Everyone is a winner in 2015 ╮ (. ❛ ᴗ ❛.) ╭
    if (match.event.year.integerValue == 2015 && match.compLevel.integerValue != CompLevelFinal) {
        self.redContainerView.layer.borderWidth = 0.0f;
        self.blueContainerView.layer.borderWidth = 0.0f;
        
        self.redScoreLabel.font = notWinnerFont;
        self.blueScoreLabel.font = notWinnerFont;
    } else if (match.redScore > match.blueScore) {
        self.redContainerView.layer.borderWidth = 2.0f;
        self.blueContainerView.layer.borderWidth = 0.0f;
        
        self.redScoreLabel.font = winnerFont;
        self.blueScoreLabel.font = notWinnerFont;
    } else if (match.blueScore > match.redScore) {
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

#pragma mark - Cell Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.redContainerView.layer.borderColor = [UIColor redColor].CGColor;
    self.blueContainerView.layer.borderColor = [UIColor blueColor].CGColor;
}

#pragma mark - Private Methods

- (UILabel *)labelForTeam:(Team *)team {
    UILabel *teamLabel = [[UILabel alloc] init];
    teamLabel.text = team.teamNumber.stringValue;
    teamLabel.font = [UIFont systemFontOfSize:14.0f];
    teamLabel.textAlignment = NSTextAlignmentCenter;
    teamLabel.backgroundColor = [UIColor clearColor];
    return teamLabel;
}

- (NSArray<UIColor *> *)storeBaseColorsForView:(NSArray<UIView *> *)views {
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    for (UIView *view in views) {
        [colors addObject:view.backgroundColor];
    }
    return colors;
}

- (void)restoreBaseColors:(NSArray<UIColor *> *)colors forViews:(NSArray<UIView *> *)views {
    if (colors.count != views.count) {
        return;
    }

    for (int i = 0; i < colors.count; i++) {
        UIView *view = views[i];
        view.backgroundColor = colors[i];
    }
}

@end
