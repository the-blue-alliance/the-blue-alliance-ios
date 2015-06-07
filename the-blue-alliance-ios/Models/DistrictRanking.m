//
//  DistrictRanking.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictRanking.h"
#import "EventPoints.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "District.h"
#import "Event+Fetch.h"

@implementation DistrictRanking

@dynamic pointTotal;
@dynamic rank;
@dynamic rookieBonus;
@dynamic team;
@dynamic district;
@dynamic eventPoints;

typedef DistrictRanking* (^Something)(Team *);

+ (instancetype)insertDistrictRankingWithDistrictRankingDict:(NSDictionary *)districtRankingDict forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictRanking" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSString *teamKey = districtRankingDict[@"team_key"];

    dispatch_semaphore_t teamSemaphore = dispatch_semaphore_create(0);
    __block Team *team;
    
    [Team fetchTeamForKey:teamKey fromContext:context withCompletionBlock:^(Team *localTeam, NSError *error) {
        if (error || !localTeam) {
            [[TBAKit sharedKit] fetchTeamForTeamKey:teamKey withCompletionBlock:^(TBATeam *upstreamTeam, NSError *error) {
                if (error || !upstreamTeam) {
                    // I guess it was never meant to be.
                    dispatch_semaphore_signal(teamSemaphore);
                } else {
                    team = [Team insertTeamWithModelTeam:upstreamTeam inManagedObjectContext:context];
                    dispatch_semaphore_signal(teamSemaphore);
                }
            }];
        } else {
            team = localTeam;
            dispatch_semaphore_signal(teamSemaphore);
        }
    }];
    dispatch_semaphore_wait(teamSemaphore, DISPATCH_TIME_FOREVER);

    if (team == nil) {
        return nil;
    }
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"district == %@ AND team == %@", district, team];
    [fetchRequest setPredicate:predicate];
    
    DistrictRanking *districtRanking;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        districtRanking = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (DistrictRanking *dr in existingObjs) {
            [context deleteObject:dr];
        }
    }
    
    if (districtRanking == nil) {
        districtRanking = [NSEntityDescription insertNewObjectForEntityForName:@"DistrictRanking" inManagedObjectContext:context];
    }
    
    districtRanking.district = district;
    districtRanking.pointTotal = [districtRankingDict[@"point_total"] intValue];
    districtRanking.rank = [districtRankingDict[@"rank"] intValue];
    districtRanking.rookieBonus = [districtRankingDict[@"rookie_bonus"] intValue];
    districtRanking.team = team;
    
    NSDictionary *eventPointsDict = districtRankingDict[@"event_points"];
    for (NSString *eventKey in [eventPointsDict allKeys]) {
        NSDictionary *eventPointDict = eventPointsDict[eventKey];
        
        dispatch_semaphore_t eventSemaphore = dispatch_semaphore_create(0);
        __block Event *event;
        
        [Event fetchEventForKey:eventKey fromContext:context withCompletionBlock:^(Event *localEvent, NSError *error) {
            if (error || !event) {
                [[TBAKit sharedKit] fetchEventForEventKey:eventKey withCompletionBlock:^(TBAEvent *upstreamEvent, NSError *error) {
                    if (error || !event) {
                        dispatch_semaphore_signal(eventSemaphore);
                    } else {
                        event = [Event insertEventWithModelEvent:upstreamEvent inManagedObjectContext:context];
                        dispatch_semaphore_signal(eventSemaphore);
                    }
                }];
            } else {
                event = localEvent;
                dispatch_semaphore_signal(eventSemaphore);
            }
        }];
        
        dispatch_semaphore_wait(eventSemaphore, DISPATCH_TIME_FOREVER);
        if (event == nil) {
            continue;
        }

        [districtRanking addEventPointsObject:[EventPoints insertEventPointsWithEventPointsDict:eventPointDict forEvent:event andTeam:team inManagedObjectContext:context]];
    }

    return districtRanking;
}

+ (NSArray *)insertDistrictRankingsWithDistrictRankings:(NSArray *)districtRankings forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *districtRanking in districtRankings) {
        [arr addObject:[self insertDistrictRankingWithDistrictRankingDict:districtRanking forDistrict:district inManagedObjectContext:context]];
    }
    return arr;
}

@end
