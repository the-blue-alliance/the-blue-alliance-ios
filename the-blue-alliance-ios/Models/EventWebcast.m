//
//  EventWebcast.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "EventWebcast.h"
#import "Event.h"

@implementation EventWebcast

@dynamic channel;
@dynamic file;
@dynamic webcastType;
@dynamic event;

+ (instancetype)insertEventWebcastWithModelEventWebcast:(TBAEventWebcast *)modelEventWebcast forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@ AND webcastType == %@ AND channel == %@",
                              event, @(modelEventWebcast.type), modelEventWebcast.channel];;
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(EventWebcast *eventWebcast) {
        eventWebcast.webcastType = @(modelEventWebcast.type);
        eventWebcast.channel = modelEventWebcast.channel;
        eventWebcast.file = modelEventWebcast.file;
        eventWebcast.event = event;
    }];
}

+ (NSArray *)insertEventWebcastsWithModelEventWebcasts:(NSArray<TBAEventWebcast *> *)modelEventWebcasts forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAEventWebcast *eventWebcast in modelEventWebcasts) {
        [arr addObject:[self insertEventWebcastWithModelEventWebcast:eventWebcast forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
