//
//  Event.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
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

// This is used internally for some data modeling
// Used as values for week on events without standard weeks
typedef NS_ENUM(NSInteger, EventOrder) {
    EventOrderPreseason = 0,
    EventOrderChampionship = 99,
    EventOrderOffseason = 100,
    EventOrderUnlabeled = 101
};


@class Award, EventAlliance, EventPoints, EventRanking, EventWebcast, Match, Team;

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSManagedObject

- (nonnull NSString *)friendlyNameWithYear:(BOOL)withYear;
- (nonnull NSString *)dateString;
- (nonnull NSString *)hybridString;

+ (nonnull NSString *)stringForEventOrder:(EventOrder)order;
+ (NSArray<NSNumber *> *)groupEventsByWeek:(NSArray<Event *> *)events;

+ (instancetype)insertEventWithModelEvent:(TBAEvent *)modelEvent inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray<Event *> *)insertEventsWithModelEvents:(NSArray<TBAEvent *> *)modelEvents inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "Event+CoreDataProperties.h"
