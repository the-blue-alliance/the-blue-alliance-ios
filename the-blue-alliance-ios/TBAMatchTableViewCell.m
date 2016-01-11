//
//  TBAMatchTableViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMatchTableViewCell.h"
#import "Event.h"

@interface TBAMatchTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *matchNumberLabel;

@property (nonatomic, weak) IBOutlet UIView *redContainerView;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray<UILabel *> *redLabels;
@property (nonatomic, weak) IBOutlet UILabel *red1Label;
@property (nonatomic, weak) IBOutlet UILabel *red2Label;
@property (nonatomic, weak) IBOutlet UILabel *red3Label;
@property (nonatomic, weak) IBOutlet UILabel *redScoreLabel;

@property (nonatomic, weak) IBOutlet UIView *blueContainerView;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray<UILabel *> *blueLabels;
@property (nonatomic, weak) IBOutlet UILabel *blue1Label;
@property (nonatomic, weak) IBOutlet UILabel *blue2Label;
@property (nonatomic, weak) IBOutlet UILabel *blue3Label;
@property (nonatomic, weak) IBOutlet UILabel *blueScoreLabel;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) NSArray<UIView *> *coloredViews;

@end

@implementation TBAMatchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.redContainerView.layer.borderColor = [UIColor redColor].CGColor;
    self.blueContainerView.layer.borderColor = [UIColor blueColor].CGColor;
}

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

#pragma mark - Properities

- (NSArray<UIView *> *)coloredViews {
    return @[self.redContainerView, self.redScoreLabel, self.blueContainerView, self.blueScoreLabel];
}

- (void)setMatch:(Match *)match {
    _match = match;
    
    self.matchNumberLabel.text = [_match friendlyMatchName];
    
    NSArray<NSString *> *redAlliance = _match.redAlliance;
    NSArray<NSString *> *blueAlliance = _match.blueAlliance;

    for (int i = 0; i < redAlliance.count; i++) {
        UILabel *label = self.redLabels[i];
        NSString *team = redAlliance[i];
        
        label.text = [team substringFromIndex:3];
    }
    self.redScoreLabel.text = _match.redScore.stringValue;
    
    for (int i = 0; i < blueAlliance.count; i++) {
        UILabel *label = self.blueLabels[i];
        NSString *team = blueAlliance[i];
        
        label.text = [team substringFromIndex:3];
    }
    self.blueScoreLabel.text = _match.blueScore.stringValue;
    
    if (_match.blueScore.integerValue < 0 && _match.redScore.integerValue < 0) {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = _match.timeString;
        
        self.redScoreLabel.hidden = YES;
        self.blueScoreLabel.hidden = YES;
    } else {
        self.timeLabel.hidden = YES;

        self.redScoreLabel.hidden = NO;
        self.blueScoreLabel.hidden = NO;
    }

    // Everyone is a winner in 2015 ╮ (. ❛ ᴗ ❛.) ╭
    if (_match.event.year.integerValue == 2015 && _match.compLevel.integerValue != CompLevelFinal) {
        self.redContainerView.layer.borderWidth = 0.0f;
        self.blueContainerView.layer.borderWidth = 0.0f;
    } else if (_match.redScore > _match.blueScore) {
        self.redContainerView.layer.borderWidth = 2.0f;
        self.blueContainerView.layer.borderWidth = 0.0f;
    } else if (_match.blueScore > _match.redScore) {
        self.blueContainerView.layer.borderWidth = 2.0f;
        self.redContainerView.layer.borderWidth = 0.0f;
    } else {
        self.redContainerView.layer.borderWidth = 0.0f;
        self.blueContainerView.layer.borderWidth = 0.0f;
    }
}

@end
