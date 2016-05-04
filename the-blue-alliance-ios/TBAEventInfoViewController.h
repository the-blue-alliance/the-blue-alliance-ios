//
//  TBAEventInfoViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBARefreshTableViewController.h"

@class Event;

@interface TBAEventInfoViewController : TBARefreshTableViewController

@property (nonatomic, strong) Event *event;

@property (nonatomic, copy,) void (^showAlliances)();
@property (nonatomic, copy,) void (^showDistrictPoints)();
@property (nonatomic, copy,) void (^showStats)();
@property (nonatomic, copy,) void (^showAwards)();

@end
