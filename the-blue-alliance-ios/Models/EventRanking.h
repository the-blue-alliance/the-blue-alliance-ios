//
//  EventRanking.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBAManagedObject.h"

@class Event, Team;

NS_ASSUME_NONNULL_BEGIN

@interface EventRanking : TBAManagedObject

@property (nullable, nonatomic, retain) NSDictionary<NSString *, NSString *> *info;
@property (nonatomic, retain) NSNumber *rank;
@property (nullable, nonatomic, retain) NSString *record;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Team *team;

- (NSString *)infoString;

+ (instancetype)insertEventRankingWithEventRankingArray:(NSArray<NSString *> *)eventRankingArray withKeys:(NSArray *)keys forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventRankingsWithEventRankings:(NSArray<NSArray *> *)eventRankings forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
