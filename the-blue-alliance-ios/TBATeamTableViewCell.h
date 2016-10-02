//
//  TeamsTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAMyTBATableViewCell.h"

static NSString *const TeamCellReuseIdentifier = @"TeamCell";

@class Team;

@interface TBATeamTableViewCell : TBAMyTBATableViewCell

@property (nonatomic, strong) Team *team;

@end
