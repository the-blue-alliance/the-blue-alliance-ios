//
//  TBAMatchesViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event, Team, Match;

@interface TBAMatchesViewController : TBARefreshTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) Team *team;

@property (nonatomic, copy) void (^matchSelected)(Match *match);

@end
