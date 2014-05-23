//
//  Team.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/22/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

/** `Team` is a data model for a team
 *  http://www.thebluealliance.com/apidocs#team-model
 */
@interface Team : NSManagedObject

/** TBA team key with the format frcyyyy
 */
@property (nonatomic, retain) NSString *key;

/** Official team number issued by FIRST
 */
@property (nonatomic, retain) NSNumber *number;

/** Official long form name registered with FIRST
 */
@property (nonatomic, retain) NSString *name;

/** Team nickname provided by FIRST
 */
@property (nonatomic, retain) NSString *nickname;

/** ?????
 */
@property (nonatomic, retain) NSString *address;

/** The last time this object was updated from data on TBA
 */
@property (nonatomic, retain) NSNumber *last_updated;

/** List of event models that the team attended for the year requested
 */
@property (nonatomic, retain) NSSet *events;
@end

@interface Team (CoreDataGeneratedAccessors)

/** Add an event for a team
 *
 * @param value The Event object to be added
 */
- (void)addEventsObject:(Event *)value;

/** Remove an event for a team
 *
 * @param value The Event object to be removed
 */
- (void)removeEventsObject:(Event *)value;

/** Add a list of events for the team
 *
 * @param values A set of Event objects to be added
 */
- (void)addEvents:(NSSet *)values;

/** Remove a list of events for the team
 *
 * @param values A set of Event objects to be removed
 */
- (void)removeEvents:(NSSet *)values;

@end
