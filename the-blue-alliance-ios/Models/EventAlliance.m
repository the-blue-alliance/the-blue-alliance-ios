//
//  EventAlliance.m
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventAlliance.h"
#import "Event.h"

@implementation EventAlliance

+ (instancetype)insertEventAllianceWithModelEventAlliance:(TBAEventAlliance *)modelEventAlliance withAllianceNumber:(int)number forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    // Check for pre-existing object
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EventAlliance" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@ AND allianceNumber == %@", event, @(number)];
    [fetchRequest setPredicate:predicate];

    EventAlliance *eventAlliance;
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    if(existingObjs.count == 1) {
        eventAlliance = [existingObjs firstObject];
    } else if(existingObjs.count > 1) {
        // Delete them all, create a new a single new one
        for (EventAlliance *ea in existingObjs) {
            [context deleteObject:ea];
        }
    }
    
    if (eventAlliance == nil) {
        eventAlliance = [NSEntityDescription insertNewObjectForEntityForName:@"EventAlliance" inManagedObjectContext:context];
    }
    
    eventAlliance.picks = modelEventAlliance.picks;
    eventAlliance.declines = modelEventAlliance.declines;
    eventAlliance.event = event;
    eventAlliance.allianceNumber = @(number);
    
    return eventAlliance;
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
