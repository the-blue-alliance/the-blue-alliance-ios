//
//  TBAEventsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

@class OrderedDictionary, Event;

@interface TBAEventsViewController : TBATableViewController

@property (nonatomic, copy) OrderedDictionary *events;
@property (nonatomic, copy) void (^eventSelected)(Event *event);

@end
