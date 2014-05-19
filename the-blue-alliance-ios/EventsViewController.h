//
//  EventsViewController.h
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "SearchableCoreDataTableViewController.h"

@interface EventsViewController : SearchableCoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
