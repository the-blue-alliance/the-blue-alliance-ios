//
//  TBAMyTBATableViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 10/1/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event, Team, Match;

@interface TBAMyTBATableViewController : TBARefreshTableViewController

@property (nonatomic, assign) Class modelClass;

@property (nonatomic, copy) void (^eventSelected)(Event *event);
@property (nonatomic, copy) void (^eventSettingsTapped)(id myTBAObject, Event *event);

@property (nonatomic, copy) void (^teamSelected)(Team *team);
@property (nonatomic, copy) void (^teamSettingsTapped)(id myTBAObject, Team *team);

@property (nonatomic, copy) void (^matchSelected)(Match *match);

@end
