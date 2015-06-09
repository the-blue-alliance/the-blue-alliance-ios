//
//  TeamsTableViewCell.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team;

@interface TBATeamTableViewCell : UITableViewCell

@property (nonatomic, weak) Team *team;

@end
