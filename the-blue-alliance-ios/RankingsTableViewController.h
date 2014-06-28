//
//  RankingsTableViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/25/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

/** `RankingsTableView` is a subview of `EventViewController`
 *  This view shows the rankings of teams at an event
 */
@interface RankingsTableViewController : UITableViewController

/** The event for which to display rankings
 */
@property (nonatomic, strong) Event *event;

/** The context to be used for accessing Core Data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

@end
