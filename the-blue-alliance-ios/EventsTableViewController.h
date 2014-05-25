//
//  EventsViewController.h
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "SearchableCoreDataTableViewController.h"
#import "YearSelectView.h"

/** `EventsTableViewController` is The table view that lists all events for a season. Events are
 *  ordered by week/event type (Week %d, Offseason, Preseason, etc). The can be filtered down
 *  by searching for an event name or an event code. Which year's data to display can be 
 *  changed using the YearSelect.
 */
@interface EventsTableViewController : SearchableCoreDataTableViewController <YearSelectDelegate, NSFetchedResultsControllerDelegate>

/** The context to be used for accessing Core Data
 */
@property (nonatomic, strong) NSManagedObjectContext *context;

@end
