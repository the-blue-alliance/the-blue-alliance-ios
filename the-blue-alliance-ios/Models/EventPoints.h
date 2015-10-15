//
//  EventPoints.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DistrictRanking, Event, Team;

NS_ASSUME_NONNULL_BEGIN

@interface EventPoints : NSManagedObject

+ (instancetype)insertEventPointsWithEventPointsDict:(NSDictionary<NSString *, NSNumber *> *)eventPointsDict forEvent:(Event *)event andTeam:(Team *)team inManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "EventPoints+CoreDataProperties.h"
