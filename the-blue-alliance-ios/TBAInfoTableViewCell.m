//
//  TBAInfoTableViewCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAInfoTableViewCell.h"
#import "Team.h"
#import "Event.h"

@interface TBAInfoTableViewCell ()

@property (nonatomic, strong) IBOutlet UIStackView *infoStackView;

@end

@implementation TBAInfoTableViewCell

- (UILabel *)titleLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:16.0f];
    return label;
}

- (UILabel *)subtitleLabelWithText:(NSString *)text {
    UILabel *label = [self titleLabelWithText:text];
    label.textColor = [UIColor darkGrayColor];
    return label;
}

- (void)setEvent:(Event *)event {
    _event = event;
    _team = nil;
    
    [self configureCell];
}

- (void)setTeam:(Team *)team {
    _team = team;
    
    [self configureCell];
}

- (void)configureCell {
    for (UIView *view in self.infoStackView.arrangedSubviews) {
        [view removeFromSuperview];
        [self.infoStackView removeArrangedSubview:view];
    }
    
    if (self.team) {
        if (self.team.nickname) {
            UILabel *nicknameLabel = [self titleLabelWithText:self.team.nickname];
            [self.infoStackView addArrangedSubview:nicknameLabel];
        }
        if (self.team.location) {
            UILabel *locationLabel = [self subtitleLabelWithText:[NSString stringWithFormat:@"from %@", self.team.location]];
            [self.infoStackView addArrangedSubview:locationLabel];
        }
//        if (self.team.name) {
//            UILabel *nameLabel = [self subtitleLabelWithText:self.team.name];
//            nameLabel.numberOfLines = 3;
//            [self.infoStackView addArrangedSubview:nameLabel];
//        }
        if (self.team.motto) {
            UILabel *mottoLabel = [self subtitleLabelWithText:self.team.motto];
            [self.infoStackView addArrangedSubview:mottoLabel];
        }
    } else if (self.event) {
        if (self.event.name) {
            UILabel *nameLabel = [self titleLabelWithText:self.event.name];
            [self.infoStackView addArrangedSubview:nameLabel];
        }
        if (self.event.location) {
            UILabel *locationLabel = [self subtitleLabelWithText:self.event.location];
            [self.infoStackView addArrangedSubview:locationLabel];
        }
        if ([self.event dateString]) {
            UILabel *dateLabel = [self subtitleLabelWithText:[self.event dateString]];
            [self.infoStackView addArrangedSubview:dateLabel];
        }
    }
}

@end
