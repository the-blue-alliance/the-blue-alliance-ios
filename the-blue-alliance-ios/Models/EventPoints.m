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

+ (instancetype)insertEventPointsWithEventPointsDict:(NSDictionary<NSString *, NSNumber *> *)eventPointsDict forEvent:(Event *)event andTeam:(Team *)team inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EventPoints" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@ AND event == %@", team, event];
    [fetchRequest setPredicate:predicate];
    
    EventPoints *eventPoints;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    
    if(existingObjs.count == 1) {
        eventPoints = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (EventPoints *ep in existingObjs) {
            [context deleteObject:ep];
        }
    }
    
    if (eventPoints == nil) {
        eventPoints = [NSEntityDescription insertNewObjectForEntityForName:@"EventPoints" inManagedObjectContext:context];
    }
    
    eventPoints.team = team;
    eventPoints.event = event;
    eventPoints.alliancePoints = eventPointsDict[@"alliance_points"];
    eventPoints.awardPoints = eventPointsDict[@"award_points"];
    eventPoints.elimPoints = eventPointsDict[@"elim_points"];
    eventPoints.districtCMP = eventPointsDict[@"district_cmp"];
    eventPoints.total = eventPointsDict[@"total"];
    eventPoints.qualPoints = eventPointsDict[@"qual_points"];
    
    return eventPoints;
}

@end
