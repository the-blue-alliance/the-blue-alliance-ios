//
//  Team.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DistrictRanking, Event, EventPoints, EventRanking, Media;

NS_ASSUME_NONNULL_BEGIN

@interface Team : NSManagedObject

+ (instancetype)insertTeamWithModelTeam:(TBATeam *)modelTeam inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)insertTeamsWithModelTeams:(NSArray<TBATeam *> *)modelTeams inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSArray *)sortedEventsForYear:(NSInteger)year;
- (NSArray *)sortedYearsParticipated;

@end

NS_ASSUME_NONNULL_END

#import "Team+CoreDataProperties.h"
