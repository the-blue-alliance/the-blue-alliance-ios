//
//  TBAMatchesViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

@class Event, Match;

@interface TBAMatchesViewController : TBATableViewController

@property (nonatomic, strong) Event *event;
@property (nonatomic, copy) void (^matchSelected)(Match *match);

@end
