//
//  TBATeamSummaryViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/25/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event, EventRanking, Team;

@interface TBATeamAtEventSummaryViewController : TBARefreshTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) EventRanking *eventRanking;

@end
