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

@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@end

@implementation TBATeamTableViewCell

- (void)setTeam:(Team *)team {
    _team = team;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%@", team.teamNumber];
    self.nameLabel.text = team.nickname;
    self.locationLabel.text = team.location;
}

@end
