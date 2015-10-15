//
//  TBAEventsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

@class District, Event, Team;

@interface TBAEventsViewController : TBATableViewController <TBATableViewControllerDelegate>

@property (nonatomic, strong) NSPredicate *predicate;

@property (nonatomic, weak) Team *team;
@property (nonatomic, weak) District *district;

@property (nonatomic, copy) void (^eventSelected)(Event *event);

@end
