//
//  DistrictRanking.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class District, EventPoints, Team;

NS_ASSUME_NONNULL_BEGIN

@interface DistrictRanking : NSManagedObject

+ (instancetype)insertDistrictRankingWithDistrictRankingDict:(NSDictionary<NSString *, id> *)districtRankingDict forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertDistrictRankingsWithDistrictRankings:(NSArray<NSDictionary<NSString *, id> *> *)districtRankings forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "DistrictRanking+CoreDataProperties.h"
