//
//  DistrictRanking.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventPoints, Team, District;

@interface DistrictRanking : NSManagedObject

@property (nonatomic, retain) District *district;
@property (nonatomic) int32_t pointTotal;
@property (nonatomic) int32_t rank;
@property (nonatomic) int32_t rookieBonus;
@property (nonatomic, retain) Team *team;
@property (nonatomic, retain) NSSet *eventPoints;

+ (instancetype)insertDistrictRankingWithDistrictRankingDict:(NSDictionary *)districtRankingDict forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertDistrictRankingsWithDistrictRankings:(NSArray *)districtRankings forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface DistrictRanking (CoreDataGeneratedAccessors)

- (void)addEventPointsObject:(EventPoints *)value;
- (void)removeEventPointsObject:(EventPoints *)value;
- (void)addEventPoints:(NSSet *)values;
- (void)removeEventPoints:(NSSet *)values;

@end
