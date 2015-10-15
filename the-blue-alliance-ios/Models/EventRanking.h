//
//  EventRanking.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Team;

NS_ASSUME_NONNULL_BEGIN

@interface EventRanking : NSManagedObject

+ (instancetype)insertEventRankingWithEventRankingArray:(NSArray<NSString *> *)eventRankingArray withKeys:(NSArray *)keys forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertEventRankingsWithEventRankings:(NSArray<NSArray *> *)eventRankings forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context;
- (NSString *)infoString;

@end

NS_ASSUME_NONNULL_END

#import "EventRanking+CoreDataProperties.h"
