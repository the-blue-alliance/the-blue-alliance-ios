//
//  EventAlliance.m
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventAlliance.h"
#import "Team.h"
#import "Event.h"

@implementation EventAlliance

@dynamic allianceNumber;
@dynamic event;
@dynamic picks;
@dynamic declines;

+ (instancetype)insertEventAllianceWithModelEventAlliance:(TBAEventAlliance *)modelEventAlliance withAllianceNumber:(int)number forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@ AND allianceNumber == %@", event, @(number)];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(EventAlliance *eventAlliance) {
        dispatch_group_t group = dispatch_group_create();
        
        NSMutableOrderedSet<Team *> *picks = [[NSMutableOrderedSet alloc] init];
        for (NSString *teamKey in modelEventAlliance.picks) {
            dispatch_group_enter(group);
            [Team fetchTeamWithKey:teamKey inManagedObjectContext:context withCompletionBlock:^(Team * _Nonnull team, NSError * _Nonnull error) {
                if (team) {
                    [picks addObject:team];
                }
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        eventAlliance.picks = picks;

        NSMutableOrderedSet<Team *> *declines = [[NSMutableOrderedSet alloc] init];
        for (NSString *teamKey in modelEventAlliance.declines) {
            dispatch_group_enter(group);
            [Team fetchTeamWithKey:teamKey inManagedObjectContext:context withCompletionBlock:^(Team * _Nonnull team, NSError * _Nonnull error) {
                if (team) {
                    [declines addObject:team];
                }
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        eventAlliance.declines = declines;
        
        eventAlliance.event = event;
        eventAlliance.allianceNumber = @(number);
    }];
}

+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray<TBAEventAlliance *> *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < modelEventAlliances.count; i++) {
        TBAEventAlliance *eventAlliance = [modelEventAlliances objectAtIndex:i];
        [arr addObject:[self insertEventAllianceWithModelEventAlliance:eventAlliance withAllianceNumber:(i + 1) forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}


@end
