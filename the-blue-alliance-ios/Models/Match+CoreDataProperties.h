//
//  Match+CoreDataProperties.h
//  the-blue-alliance
//
//  Created by Zach Orr on 11/1/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Match.h"

NS_ASSUME_NONNULL_BEGIN

@interface Match (CoreDataProperties)

@property (nullable, nonatomic, retain) id blueAlliance;
@property (nullable, nonatomic, retain) NSNumber *blueScore;
@property (nullable, nonatomic, retain) NSNumber *compLevel;
@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSNumber *matchNumber;
@property (nullable, nonatomic, retain) id redAlliance;
@property (nullable, nonatomic, retain) NSNumber *redScore;
@property (nullable, nonatomic, retain) id scoreBreakdown;
@property (nullable, nonatomic, retain) NSNumber *setNumber;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) Event *event;
@property (nullable, nonatomic, retain) NSSet<MatchVideo *> *vidoes;

@end

@interface Match (CoreDataGeneratedAccessors)

- (void)addVidoesObject:(MatchVideo *)value;
- (void)removeVidoesObject:(MatchVideo *)value;
- (void)addVidoes:(NSSet<MatchVideo *> *)values;
- (void)removeVidoes:(NSSet<MatchVideo *> *)values;

@end

NS_ASSUME_NONNULL_END
