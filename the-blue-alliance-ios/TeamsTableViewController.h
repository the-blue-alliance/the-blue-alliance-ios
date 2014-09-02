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
#import <GDIIndexBar/GDIIndexBar.h>

/** TeamsViewController is a table view of all teams registered in FRC
 *  (past and current)
 */
@interface TeamsTableViewController : SearchableCoreDataTableViewController <GDIIndexBarDelegate, UITableViewDataSource>

/** The context to be used for accessing Core Data
*/
@property (nonatomic, strong) NSManagedObjectContext *context;

/** The event to show teams at
 *  If nil, will show all teams
 */
@property (nonatomic, strong) Event *eventFilter;

/**
 *  Whether or not the TeamsTableViewController should disable sectioning of teams by the 1000's
 */
@property (nonatomic) BOOL disableSections;

@property (nonatomic, strong) GDIIndexBar *indexBar;

@end
