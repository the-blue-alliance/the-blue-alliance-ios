//
//  DistrictRanking.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictRanking.h"
#import "District.h"
#import "EventPoints.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Event+Fetch.h"

@implementation DistrictRanking

@dynamic pointTotal;
@dynamic rank;
@dynamic rookieBonus;
@dynamic district;
@dynamic eventPoints;
@dynamic team;

+ (instancetype)insertDistrictRankingWithDistrictRankingDict:(NSDictionary<NSString *, id> *)districtRankingDict forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context {
    NSString *teamKey = districtRankingDict[@"team_key"];
    
    dispatch_semaphore_t teamSemaphore = dispatch_semaphore_create(0);
    __block Team *team;
    
    [Team fetchTeamForKey:teamKey fromContext:context checkUpstream:YES withCompletionBlock:^(Team *localTeam, NSError *error) {
        if (error || !localTeam) {
            dispatch_semaphore_signal(teamSemaphore);
        } else {
            team = localTeam;
            dispatch_semaphore_signal(teamSemaphore);
        }
    }];
    dispatch_semaphore_wait(teamSemaphore, DISPATCH_TIME_FOREVER);
    
    if (team == nil) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"district == %@ AND team == %@", district, team];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(DistrictRanking *districtRanking) {
        District *d = [context objectWithID:district.objectID];
        
        districtRanking.district = d;
        districtRanking.pointTotal = districtRankingDict[@"point_total"];
        districtRanking.rank = districtRankingDict[@"rank"];
        districtRanking.rookieBonus = districtRankingDict[@"rookie_bonus"];
        districtRanking.team = team;
        
        NSDictionary *eventPointsDict = districtRankingDict[@"event_points"];
        for (NSString *eventKey in [eventPointsDict allKeys]) {
            NSDictionary *eventPointDict = eventPointsDict[eventKey];
            
            dispatch_semaphore_t eventSemaphore = dispatch_semaphore_create(0);
            __block Event *event;
            
            [Event fetchEventForKey:eventKey fromContext:context checkUpstream:YES withCompletionBlock:^(Event *localEvent, NSError *error) {
                if (error || !event) {
                    dispatch_semaphore_signal(eventSemaphore);
                } else {
                    event = localEvent;
                    dispatch_semaphore_signal(eventSemaphore);
                }
            }];
            
            dispatch_semaphore_wait(eventSemaphore, DISPATCH_TIME_FOREVER);
            if (event == nil) {
                continue;
            }
            
            districtRanking.eventPoints = [districtRanking.eventPoints setByAddingObject:[EventPoints insertEventPointsWithEventPointsDict:eventPointDict forEvent:event andTeam:team inManagedObjectContext:context]];
        }
    }];
}

+ (NSArray *)insertDistrictRankingsWithDistrictRankings:(NSArray<NSDictionary<NSString *, id> *> *)districtRankings forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *districtRanking in districtRankings) {
        [arr addObject:[self insertDistrictRankingWithDistrictRankingDict:districtRanking forDistrict:district inManagedObjectContext:context]];
    }
    return arr;
}

@end
