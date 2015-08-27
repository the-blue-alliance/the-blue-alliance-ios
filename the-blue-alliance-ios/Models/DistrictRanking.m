#import "DistrictRanking.h"
#import "Team+Fetch.h"
#import "Event+Fetch.h"
#import "EventPoints.h"

@interface DistrictRanking ()

// Private interface goes here.

@end

@implementation DistrictRanking

+ (instancetype)insertDistrictRankingWithDistrictRankingDict:(NSDictionary *)districtRankingDict forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictRanking" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
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
