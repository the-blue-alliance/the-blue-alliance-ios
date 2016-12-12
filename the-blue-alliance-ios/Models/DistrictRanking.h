//
//  DistrictRanking.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class District, EventPoints, Team;

NS_ASSUME_NONNULL_BEGIN

@interface DistrictRanking : TBAManagedObject

@property (nonatomic, retain) NSNumber *pointTotal;
@property (nonatomic, retain) NSNumber *rank;
@property (nonatomic, retain) NSNumber *rookieBonus;
@property (nullable, nonatomic, retain) District *district;
@property (nullable, nonatomic, retain) NSSet<EventPoints *> *eventPoints;
@property (nullable, nonatomic, retain) Team *team;

+ (instancetype)insertDistrictRankingWithDistrictRankingDict:(NSDictionary<NSString *, id> *)districtRankingDict forDistrict:(District *)district forTeam:(Team *)team inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertDistrictRankingsWithDistrictRankings:(NSArray<NSDictionary<NSString *, id> *> *)districtRankings forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
