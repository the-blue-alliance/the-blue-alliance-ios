//
//  DistrictRanking+CoreDataProperties.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DistrictRanking.h"

NS_ASSUME_NONNULL_BEGIN

@interface DistrictRanking (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *pointTotal;
@property (nullable, nonatomic, retain) NSNumber *rank;
@property (nullable, nonatomic, retain) NSNumber *rookieBonus;
@property (nullable, nonatomic, retain) District *district;
@property (nullable, nonatomic, retain) NSSet<EventPoints *> *eventPoints;
@property (nullable, nonatomic, retain) Team *team;

@end

@interface DistrictRanking (CoreDataGeneratedAccessors)

- (void)addEventPointsObject:(EventPoints *)value;
- (void)removeEventPointsObject:(EventPoints *)value;
- (void)addEventPoints:(NSSet<EventPoints *> *)values;
- (void)removeEventPoints:(NSSet<EventPoints *> *)values;

@end

NS_ASSUME_NONNULL_END
