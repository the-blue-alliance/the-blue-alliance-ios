//
//  EventViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/24/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "TBAPaginatedViewController.h"

/** `EventViewController` is a detail view for event data.
 */
@interface EventViewController : TBAPaginatedViewController

/** Initilizes the EventViewController for a given event
 *
 * @param event The event to show data for
 * @param context The context for the Core Data calls
 * @return An initilized EventViewController
 */
- (instancetype)initWithEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context;
@end
