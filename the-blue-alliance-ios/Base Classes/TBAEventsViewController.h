//
//  TBAEventsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderedDictionary, Event;

@interface TBAEventsViewController : UIViewController

// Events should always have key "top level" label (Week 1 Events, Week 2 Events, etc)
// or, something like (Regional Events, MI District Events, etc)
// Value is an array of events
@property (nonatomic, copy) OrderedDictionary *events;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, copy) void (^eventSelected)(Event *event);

@end
