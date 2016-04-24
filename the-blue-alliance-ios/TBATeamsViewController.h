//
//  TBATeamsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event, Team;

@interface TBATeamsViewController : TBARefreshTableViewController <TBATableViewControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) Event *event;

@property (nonatomic, copy) void (^teamSelected)(Team *team);

@end
