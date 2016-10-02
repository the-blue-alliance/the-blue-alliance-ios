//
//  TBATeamAtEventStatsViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event, Team;

@interface TBATeamAtEventStatsViewController : TBARefreshTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) Event *event;

@end
