//
//  TBAInfoViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

@class Team, Event;

@interface TBAInfoViewController : TBATableViewController

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) Event *event;

@end
