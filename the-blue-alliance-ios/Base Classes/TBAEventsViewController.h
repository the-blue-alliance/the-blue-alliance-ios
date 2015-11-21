//
//  TBAEventsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class District, Event, Team;

@interface TBAEventsViewController : TBARefreshTableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) NSNumber *week;
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) District *district;

@property (nonatomic, copy) void (^eventsFetched)();
@property (nonatomic, copy) void (^eventSelected)(Event *event);

@end
