//
//  Event.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

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


@class Award, EventAlliance, EventPoints, EventRanking, EventTeamStat, EventWebcast, Match, Team;

NS_ASSUME_NONNULL_BEGIN

@interface Event : TBAManagedObject

@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSString *eventCode;
@property (nullable, nonatomic, retain) NSNumber *eventDistrict;
@property (nullable, nonatomic, retain) NSString *eventDistrictString;
@property (nonatomic, retain) NSNumber *eventType;
@property (nullable, nonatomic, retain) NSString *eventTypeString;
@property (nullable, nonatomic, retain) NSString *facebookEid;
@property (nonnull, retain) NSNumber *hybridType;
@property (nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *official;
@property (nullable, nonatomic, retain) NSString *shortName;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSDictionary *stats;
@property (nullable, nonatomic, retain) NSString *venueAddress;
@property (nullable, nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSNumber *week;
@property (nonatomic, retain) NSNumber *year;

@property (nullable, nonatomic, retain) NSSet<EventAlliance *> *alliances;
@property (nullable, nonatomic, retain) NSSet<Award *> *awards;
@property (nullable, nonatomic, retain) NSSet<Match *> *matches;
@property (nullable, nonatomic, retain) NSSet<EventPoints *> *points;
@property (nullable, nonatomic, retain) NSSet<EventRanking *> *rankings;
@property (nullable, nonatomic, retain) NSSet<Team *> *teams;
@property (nullable, nonatomic, retain) NSSet<EventTeamStat *> *teamStats;
@property (nullable, nonatomic, retain) NSSet<EventWebcast *> *webcasts;

- (nonnull NSString *)friendlyNameWithYear:(BOOL)withYear;
- (nonnull NSString *)dateString;
- (nonnull NSString *)hybridString;
- (BOOL)isDistrict;

+ (nonnull NSString *)stringForEventOrder:(NSNumber *)order;
+ (NSArray<NSNumber *> *)groupEventsByWeek:(NSArray<Event *> *)events;

+ (instancetype)insertEventWithModelEvent:(TBAEvent *)modelEvent inManagedObjectContext:(NSManagedObjectContext *)context;
+ (instancetype)insertStubEventWithKey:(NSString *)eventKey inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray<Event *> *)insertEventsWithModelEvents:(NSArray<TBAEvent *> *)modelEvents inManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface EventWeek : NSObject
+ (NSInteger)firstCompetitionWeekEventOrderForYear:(NSInteger)year;
+ (NSArray *)championshipCompetitionWeeks;
+ (NSArray *)firstCompetitionYearWeeks;
+ (NSInteger)eventOrderForDate:(NSDate *)date;
+ (NSInteger)competitionWeekForDate:(NSDate *)date;
+ (NSInteger)championshipCompetitionWeekForYear:(NSInteger)year;
@end

NS_ASSUME_NONNULL_END
