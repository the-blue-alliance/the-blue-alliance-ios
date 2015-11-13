//
//  District+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "District.h"

NS_ASSUME_NONNULL_BEGIN

@interface District (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSSet<DistrictRanking *> *districtRankings;

@end

@interface District (CoreDataGeneratedAccessors)

- (void)addDistrictRankingsObject:(DistrictRanking *)value;
- (void)removeDistrictRankingsObject:(DistrictRanking *)value;
- (void)addDistrictRankings:(NSSet<DistrictRanking *> *)values;
- (void)removeDistrictRankings:(NSSet<DistrictRanking *> *)values;

@end

NS_ASSUME_NONNULL_END
