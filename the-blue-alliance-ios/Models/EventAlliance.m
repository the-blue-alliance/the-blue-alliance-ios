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
        NSMutableSet<Team *> *picks = [[NSMutableSet alloc] init];
        for (NSString *teamKey in modelEventAlliance.picks) {
            Team *team = [Team insertStubTeamWithKey:teamKey inManagedObjectContext:context];
            [picks addObject:team];
        }
        eventAlliance.picks = picks;

        NSMutableSet<Team *> *declines = [[NSMutableSet alloc] init];
        for (NSString *teamKey in modelEventAlliance.declines) {
            Team *team = [Team insertStubTeamWithKey:teamKey inManagedObjectContext:context];
            [declines addObject:team];
        }
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
