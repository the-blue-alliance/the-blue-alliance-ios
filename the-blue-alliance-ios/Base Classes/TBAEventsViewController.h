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

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, copy) OrderedDictionary *events;
@property (nonatomic, copy) void (^eventSelected)(Event *event);

@end
