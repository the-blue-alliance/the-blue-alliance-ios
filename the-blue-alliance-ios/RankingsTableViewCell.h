//
//  RankingsTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/19/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface RankingsTableViewCell : UITableViewCell

- (void)setRankedTeamData:(NSDictionary *)team forHeaderKeys:(NSArray *)headers withTeam:(Team *)team;

@end
