//
//  Event+Fetch.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/10/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Event+Fetch.h"

@implementation Event (Fetch)

#pragma mark - Local

+ (void)fetchEventForKey:(nonnull NSString *)eventKey fromContext:(nonnull NSManagedObjectContext *)context checkUpstream:(BOOL)upstream withCompletionBlock:(void(^_Nullable)(Event *_Nullable event, NSError *_Nullable error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", eventKey];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:fetchRequest error:&error];
    
    Event *event;
    if (events && [events count] > 0) {
        event = [events firstObject];
    }
    
    if (event) {
        if (completion) {
            completion(event, error);
        }
    } else if (upstream) {
        [[TBAKit sharedKit] fetchEventForEventKey:eventKey withCompletionBlock:^(TBAEvent *upstreamEvent, NSError *error) {
            if (error || !event) {
                if (completion) {
                    completion(nil, error);
                }
            } else {
                Event *event = [Event insertEventWithModelEvent:upstreamEvent inManagedObjectContext:context];
                if (completion) {
                    completion(event,  nil);
                }
            }
        }];
    }
}

+ (void)fetchEventsForYear:(NSUInteger)year fromContext:(nonnull NSManagedObjectContext *)context withCompletionBlock:(void(^_Nullable)(NSArray<Event *> *_Nullable events, NSError *_Nullable error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@", @(year)];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *startDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[startDateSortDescriptor, nameSortDescriptor]];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:fetchRequest error:&error];
    
    if (completion) {
        completion(events, error);
    }
}

@end
