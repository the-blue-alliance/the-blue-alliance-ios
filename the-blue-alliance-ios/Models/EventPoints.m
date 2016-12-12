//
//  EventPoints.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "EventPoints.h"
#import "DistrictRanking.h"
#import "Event.h"
#import "Team.h"

@implementation EventPoints

@dynamic alliancePoints;
@dynamic awardPoints;
@dynamic districtCMP;
@dynamic elimPoints;
@dynamic qualPoints;
@dynamic total;
@dynamic districtRanking;
@dynamic event;
@dynamic team;

+ (instancetype)insertEventPointsWithEventPointsDict:(NSDictionary<NSString *, NSNumber *> *)eventPointsDict forEvent:(Event *)event andTeam:(Team *)team inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@ AND event == %@", team, event];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(EventPoints *eventPoints) {
        eventPoints.team = team;
        eventPoints.event = event;
        eventPoints.alliancePoints = eventPointsDict[@"alliance_points"];
        eventPoints.awardPoints = eventPointsDict[@"award_points"];
        
        eventPoints.districtCMP = eventPointsDict[@"district_cmp"];
        if (!eventPoints.districtCMP) {
            eventPoints.districtCMP = @(event.eventType.integerValue == TBAEventTypeDistrictCMP);
        }
        
        eventPoints.elimPoints = eventPointsDict[@"elim_points"];
        eventPoints.total = eventPointsDict[@"total"];
        eventPoints.qualPoints = eventPointsDict[@"qual_points"];
    }];
}

+ (NSArray *)insertEventPointsWithEventPointsDict:(NSDictionary<NSString *, NSDictionary *> *)eventPointsDict forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *eventPoints = [[NSMutableArray alloc] init];
    for (NSString *teamKey in eventPointsDict.allKeys) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        __block Team *team;
        [Team fetchTeamWithKey:teamKey inManagedObjectContext:context withCompletionBlock:^(Team * _Nonnull t, NSError * _Nonnull error) {
            team = t;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if (!team) {
            continue;
        }
        
        NSDictionary *teamPointsDict = eventPointsDict[teamKey];
        [eventPoints addObject:[self insertEventPointsWithEventPointsDict:teamPointsDict forEvent:event andTeam:team inManagedObjectContext:context]];
    }
    return eventPoints;
}

@end
