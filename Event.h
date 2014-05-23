//
//  Event.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/22/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Team;

@interface Event : NSManagedObject

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

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * district_enum;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSString * event_short;
@property (nonatomic, retain) NSNumber * event_type;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSNumber * last_updated;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * official;
@property (nonatomic, retain) NSString * short_name;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSString * stats;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSString * venue;
@property (nonatomic, retain) NSString * webcasts;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * rankings;
@property (nonatomic, retain) NSSet *teams;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addTeamsObject:(Team *)value;
- (void)removeTeamsObject:(Team *)value;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

@end
