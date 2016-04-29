//
//  TeamsTableViewCell.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATeamTableViewCell.h"
#import "Team.h"

@interface TBATeamTableViewCell ()

@property (nonatomic, strong) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;

@end

@implementation TBATeamTableViewCell

- (void)setTeam:(Team *)team {
    _team = team;
    
    if (self.team.name) {
        self.nameLabel.text = team.nickname;
    } else {
        self.nameLabel.text = [NSString stringWithFormat:@"Team %@", team.teamNumber];
    }
    if (self.team.location) {
        self.locationLabel.text = team.location;
    } else {
        self.locationLabel.text = @"";
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%@", team.teamNumber];
}

@end
