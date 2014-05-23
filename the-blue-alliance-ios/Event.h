//
//  Event.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/22/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/** The constants for events
 *  https://github.com/the-blue-alliance/the-blue-alliance/blob/master/consts/event_type.py#L2
 */
typedef enum EventType : NSInteger {
    REGIONAL = 0,
    DISTRICT = 1,
    DISTRICT_CMP = 2,
    CMP_DIVISION = 3,
    CMP_FINALS = 4,
    OFFSEASON = 99,
    PRESEASON = 100,
    UNLABLED = -1
} EventType;

@class Team;

/** `Event` is a data model for an event
 *  http://www.thebluealliance.com/apidocs#event-model
 */
@interface Event : NSManagedObject

/** ?????
 */
@property (nonatomic, retain) NSString * address;

/** ?????
 */
@property (nonatomic, retain) NSNumber * district_enum;

/** Last day the event is taking place
 */
@property (nonatomic, retain) NSDate * end_date;

/** Event short code
 */
@property (nonatomic, retain) NSString * event_short;

/** An integer that represents the event type as a constant
 *  See EventType enum
 */
@property (nonatomic, retain) NSNumber * event_type;

/** TBA event key with the format yyyy[EVENT_CODE], where yyyy is the year,
 *  and EVENT_CODE is the event code of the event
 */
@property (nonatomic, retain) NSString * key;

/** Last time this object was updated from data on TBA
 */
@property (nonatomic, retain) NSNumber * last_updated;

/** Long form address that includes city, and state provided by FIRST
 */
@property (nonatomic, retain) NSString * location;

/** Official name of event on record either provided by FIRST or
 *  organizers of offseason event
 */
@property (nonatomic, retain) NSString * name;

/** Whether this is a FIRST official event, or an offseaon event
 *  1 if true, 0 if false
 */
@property (nonatomic, retain) NSNumber * official;

/** name but doesn't include event specifiers, such as 'Regional' or 'District'
 */
@property (nonatomic, retain) NSString * short_name;

/** First day the event is taking place
 */
@property (nonatomic, retain) NSDate * start_date;

/** ?????
 */
@property (nonatomic, retain) NSString * stats;

/** TZ database representation for the timezone
 *  http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
 */
@property (nonatomic, retain) NSString * timezone;

/** Name of the venue the event will be taking place at
 */
@property (nonatomic, retain) NSString * venue;

/** Link to the webcast(s) for the event
 */
@property (nonatomic, retain) NSString * webcasts;

/** Website for the event
 */
@property (nonatomic, retain) NSString * website;

/** Year the event data is for
 */
@property (nonatomic, retain) NSNumber * year;

/** Rankings for the event
 */
@property (nonatomic, retain) NSString * rankings;

/** List of team models that attended the event
 */
@property (nonatomic, retain) NSSet *teams;
@end

@interface Event (CoreDataGeneratedAccessors)

/** Add a team that attended the event
 *
 * @param value The Team object to be added
 */
- (void)addTeamsObject:(Team *)value;

/** Remove n team that attended the event
 *
 * @param value The Team object to be removed
 */
- (void)removeTeamsObject:(Team *)value;

/** Add a list of teams that attended the event
 *
 * @param value The Team object to be added
 */
- (void)addTeams:(NSSet *)values;

/** Remove a list of teams that attended the event
 *
 * @param value The Team object to be added
 */
- (void)removeTeams:(NSSet *)values;

@end
