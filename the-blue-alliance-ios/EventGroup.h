//
//  EventGroup.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

/** `EventGroup` is an object to hold a week's worth of events. Each group of
 *  events has a name, and an array of events associated with it
 */
@interface EventGroup : NSObject

/** The identifier for the event grouping
 */
@property (nonatomic, strong) NSString *name;

/** An array of Event objects
 */
@property (nonatomic, strong) NSMutableArray *events;

/** Initilizes the EventGroup with an name for the grouping
 *
 * @param name An identifier for the event grouping
 * @return An initilized EventGroup
 */
- (id)initWithName:(NSString*)name;

/** Adds an event to the array of events
 *
 * @param event The event object to be added to this grouping
 */
- (void)addEvent:(Event*)event;
@end
