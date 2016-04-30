//
//  EventStat.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventTeamStat.h"
#import "Team.h"

@implementation EventTeamStat

@dynamic score;
@dynamic statType;
@dynamic team;
@dynamic event;

+ (instancetype)insertEventTeamStat:(NSNumber *)score ofType:(StatType)statType forTeam:(Team *)team atEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@ AND team == %@", event, team];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(EventTeamStat *eventTeamStat) {
        eventTeamStat.statType = @(statType);
        eventTeamStat.score = score;
        eventTeamStat.team = team;
        eventTeamStat.event = event;
    }];
}

+ (NSArray *)insertEventTeamStats:(NSDictionary<NSString *, NSNumber *> *)eventTeamStats ofType:(StatType)statType forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSString *teamKey in eventTeamStats.allKeys) {
        NSNumber *statScore = eventTeamStats[teamKey];
        Team *team = [Team insertStubTeamWithKey:[NSString stringWithFormat:@"frc%@", teamKey] inManagedObjectContext:context];
        [arr addObject:[self insertEventTeamStat:statScore ofType:statType forTeam:team atEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
