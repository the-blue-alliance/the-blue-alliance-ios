//
//  TeamsViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchableCoreDataTableViewController.h"

@interface TeamsViewController : SearchableCoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *context;
@end
