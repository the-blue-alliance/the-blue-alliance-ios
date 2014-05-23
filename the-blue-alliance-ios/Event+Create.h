//
//  Event+Create.h
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Event.h"

/** `Event+Create` encapsulates all the requests for
 *  Event data to the TBA API
 */
@interface Event (Create)

/** Create an Event object from a dictionary of information
 *
 * @param info A dictionary containing keys that match properities
 *  for an event object, and values for the object
 * @param context The context for Core Datas
 * @return An Event object with the data from info
 */
+ (Event *)createEventFromTBAInfo:(NSDictionary *)info
         usingManagedObjectContext:(NSManagedObjectContext *)context;

/** Create Event objects from an array of event information
 *
 * @param infoArray An array containing sets of keys that match properities
 *  for an event object, and values for the object
 * @param context The context for Core Datas
 */
+ (void)createEventsFromTBAInfoArray:(NSArray *)infoArray
            usingManagedObjectContext:(NSManagedObjectContext *)context;

@end
