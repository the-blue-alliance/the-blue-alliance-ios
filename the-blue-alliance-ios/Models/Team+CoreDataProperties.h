//
//  Team+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Team.h"

NS_ASSUME_NONNULL_BEGIN

@interface Team (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *countryName;
@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSString *locality;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *motto;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *nickname;
@property (nullable, nonatomic, retain) NSString *region;
@property (nullable, nonatomic, retain) NSNumber *rookieYear;
@property (nullable, nonatomic, retain) NSNumber *teamNumber;
@property (nullable, nonatomic, retain) NSString *website;
@property (nullable, nonatomic, retain) id yearsParticipated;
@property (nullable, nonatomic, retain) NSSet<DistrictRanking *> *districtRankings;
@property (nullable, nonatomic, retain) NSSet<EventPoints *> *eventPoints;
@property (nullable, nonatomic, retain) NSSet<EventRanking *> *eventRankings;
@property (nullable, nonatomic, retain) NSSet<Event *> *events;
@property (nullable, nonatomic, retain) NSSet<Media *> *media;
@property (nullable, nonatomic, retain) NSSet<AwardRecipient *> *awards;

@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addDistrictRankingsObject:(DistrictRanking *)value;
- (void)removeDistrictRankingsObject:(DistrictRanking *)value;
- (void)addDistrictRankings:(NSSet<DistrictRanking *> *)values;
- (void)removeDistrictRankings:(NSSet<DistrictRanking *> *)values;

- (void)addEventPointsObject:(EventPoints *)value;
- (void)removeEventPointsObject:(EventPoints *)value;
- (void)addEventPoints:(NSSet<EventPoints *> *)values;
- (void)removeEventPoints:(NSSet<EventPoints *> *)values;

- (void)addEventRankingsObject:(EventRanking *)value;
- (void)removeEventRankingsObject:(EventRanking *)value;
- (void)addEventRankings:(NSSet<EventRanking *> *)values;
- (void)removeEventRankings:(NSSet<EventRanking *> *)values;

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet<Event *> *)values;
- (void)removeEvents:(NSSet<Event *> *)values;

- (void)addMediaObject:(Media *)value;
- (void)removeMediaObject:(Media *)value;
- (void)addMedia:(NSSet<Media *> *)values;
- (void)removeMedia:(NSSet<Media *> *)values;

- (void)addAwardsObject:(AwardRecipient *)value;
- (void)removeAwardsObject:(AwardRecipient *)value;
- (void)addAwards:(NSSet<AwardRecipient *> *)values;
- (void)removeAwards:(NSSet<AwardRecipient *> *)values;

@end

NS_ASSUME_NONNULL_END
