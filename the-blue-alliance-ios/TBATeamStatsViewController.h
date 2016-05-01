//
//  TBATeamStatsViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event, Team;

@interface TBATeamStatsViewController : TBARefreshTableViewController

@property (nonatomic, strong) Event *event;

@property (nonatomic, copy) void (^teamSelected)(Team *team);

@end
