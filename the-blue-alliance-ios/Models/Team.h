//
//  Team.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class AwardRecipient, DistrictRanking, Event, EventPoints, EventRanking, Match, Media;

NS_ASSUME_NONNULL_BEGIN

@interface Team : TBAManagedObject

@property (nullable, nonatomic, retain) NSString *countryName;
@property (nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSString *locality;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *motto;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *nickname;
@property (nullable, nonatomic, retain) NSString *region;
@property (nullable, nonatomic, retain) NSNumber *rookieYear;
@property (nonatomic, retain) NSNumber *teamNumber;
@property (nullable, nonatomic, retain) NSString *website;
@property (nullable, nonatomic, retain) id yearsParticipated;
@property (nullable, nonatomic, retain) NSSet<DistrictRanking *> *districtRankings;
@property (nullable, nonatomic, retain) NSSet<EventPoints *> *eventPoints;
@property (nullable, nonatomic, retain) NSSet<EventRanking *> *eventRankings;
@property (nullable, nonatomic, retain) NSSet<Event *> *events;
@property (nullable, nonatomic, retain) NSSet<Media *> *media;
@property (nullable, nonatomic, retain) NSSet<AwardRecipient *> *awards;
@property (nullable, nonatomic, retain) NSSet<Match *> *redMatches;
@property (nullable, nonatomic, retain) NSSet<Match *> *blueMatches;

+ (instancetype)insertTeamWithModelTeam:(TBATeam *)modelTeam inManagedObjectContext:(NSManagedObjectContext *)context;
+ (instancetype)insertStubTeamWithKey:(NSString *)teamKey inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertTeamsWithModelTeams:(NSArray<TBATeam *> *)modelTeams inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertTeamsWithModelTeams:(NSArray<TBATeam *> *)modelTeams forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSArray *)sortedEventsForYear:(NSInteger)year;
- (NSArray *)sortedYearsParticipated;
- (void)setEvents:(NSSet<Event *> * _Nullable)events forYear:(NSNumber *)year;

@end

NS_ASSUME_NONNULL_END
