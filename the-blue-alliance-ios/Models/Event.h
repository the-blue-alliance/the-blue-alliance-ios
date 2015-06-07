//
//  Event.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/10/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, EventType) {
    EventTypeRegional = 0,
    EventTypeDistrict = 1,
    EventTypeDistrictCMP = 2,
    EventTypeCMPDivision = 3,
    EventTypeCMPFinals = 4,
    EventTypeOffseason = 99,
    EventTypePreseason = 100,
    EventTypeUnlabeled = -1
};

@class EventAlliance, EventWebcast, OrderedDictionary;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * eventCode;
@property (nonatomic) int32_t eventType;
@property (nonatomic, retain) NSString * eventDistrict;
@property (nonatomic) int64_t year;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * venueAddress;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * facebookEid;
@property (nonatomic) BOOL official;
@property (nonatomic) NSTimeInterval startDate;
@property (nonatomic) NSTimeInterval endDate;
@property (nonatomic, retain) NSSet *webcasts;
@property (nonatomic, retain) NSSet *alliances;

- (NSDate *)dateStart;
- (NSDate *)dateEnd;
- (NSString *)friendlyNameWithYear:(BOOL)withYear;
- (NSString *)dateString;

+ (OrderedDictionary *)groupEventsByWeek:(NSArray *)events;

+ (instancetype)insertEventWithModelEvent:(TBAEvent *)modelEvent inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventsWithModelEvents:(NSArray *)modelEvents inManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addWebcastsObject:(EventWebcast *)value;
- (void)removeWebcastsObject:(EventWebcast *)value;
- (void)addWebcasts:(NSSet *)values;
- (void)removeWebcasts:(NSSet *)values;

- (void)addAlliancesObject:(EventAlliance *)value;
- (void)removeAlliancesObject:(EventAlliance *)value;
- (void)addAlliances:(NSSet *)values;
- (void)removeAlliances:(NSSet *)values;

@end
