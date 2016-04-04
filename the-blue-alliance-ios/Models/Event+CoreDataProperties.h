//
//  Event+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/22/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nullable, nonatomic, retain) NSString *eventCode;
@property (nullable, nonatomic, retain) NSNumber *eventDistrict;
@property (nullable, nonatomic, retain) NSNumber *eventType;
@property (nullable, nonatomic, retain) NSString *facebookEid;
@property (nullable, nonatomic, retain) NSNumber *hybridType;
@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *official;
@property (nullable, nonatomic, retain) NSString *shortName;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSString *venueAddress;
@property (nullable, nonatomic, retain) NSString *website;
@property (nullable, nonatomic, retain) NSNumber *week;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSString *eventDistrictString;
@property (nullable, nonatomic, retain) NSString *eventTypeString;
@property (nullable, nonatomic, retain) NSSet<EventAlliance *> *alliances;
@property (nullable, nonatomic, retain) NSSet<Match *> *matches;
@property (nullable, nonatomic, retain) NSSet<EventPoints *> *points;
@property (nullable, nonatomic, retain) NSSet<EventRanking *> *rankings;
@property (nullable, nonatomic, retain) NSSet<Team *> *teams;
@property (nullable, nonatomic, retain) NSSet<EventWebcast *> *webcasts;
@property (nullable, nonatomic, retain) NSSet<Award *> *awards;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addAlliancesObject:(EventAlliance *)value;
- (void)removeAlliancesObject:(EventAlliance *)value;
- (void)addAlliances:(NSSet<EventAlliance *> *)values;
- (void)removeAlliances:(NSSet<EventAlliance *> *)values;

- (void)addMatchesObject:(Match *)value;
- (void)removeMatchesObject:(Match *)value;
- (void)addMatches:(NSSet<Match *> *)values;
- (void)removeMatches:(NSSet<Match *> *)values;

- (void)addPointsObject:(EventPoints *)value;
- (void)removePointsObject:(EventPoints *)value;
- (void)addPoints:(NSSet<EventPoints *> *)values;
- (void)removePoints:(NSSet<EventPoints *> *)values;

- (void)addRankingsObject:(EventRanking *)value;
- (void)removeRankingsObject:(EventRanking *)value;
- (void)addRankings:(NSSet<EventRanking *> *)values;
- (void)removeRankings:(NSSet<EventRanking *> *)values;

- (void)addTeamsObject:(Team *)value;
- (void)removeTeamsObject:(Team *)value;
- (void)addTeams:(NSSet<Team *> *)values;
- (void)removeTeams:(NSSet<Team *> *)values;

- (void)addWebcastsObject:(EventWebcast *)value;
- (void)removeWebcastsObject:(EventWebcast *)value;
- (void)addWebcasts:(NSSet<EventWebcast *> *)values;
- (void)removeWebcasts:(NSSet<EventWebcast *> *)values;

- (void)addAwardsObject:(Award *)value;
- (void)removeAwardsObject:(Award *)value;
- (void)addAwards:(NSSet<Award *> *)values;
- (void)removeAwards:(NSSet<Award *> *)values;

@end

NS_ASSUME_NONNULL_END
