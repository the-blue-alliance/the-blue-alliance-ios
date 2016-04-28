//
//  TBARankingsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 7/3/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event, EventRanking;

@interface TBAEventRankingsViewController : TBARefreshTableViewController

@property (nonatomic, strong) Event *event;

@property (nonatomic, copy) void (^rankingSelected)(EventRanking *eventRanking);

@end
