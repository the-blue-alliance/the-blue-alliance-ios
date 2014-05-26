//
//  TeamsViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/11/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchableCoreDataTableViewController.h"
#import "Event.h"

/** `TeamsViewController` is a table view of all teams registered in FRC
 *  (past and current)
 */
@interface TeamsTableViewController : SearchableCoreDataTableViewController

/** The context to be used for accessing Core Data
*/
@property (nonatomic, strong) NSManagedObjectContext *context;

/** The event to show teams at
 *  If nil, will show all teams
 */
@property (nonatomic, strong) Event *eventFilter;
@end
