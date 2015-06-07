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

+ (void)fetchEventForKey:(NSString *)eventKey fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(Event *event, NSError *error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", eventKey];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:fetchRequest error:&error];
    
    Event *event;
    if (events && [events count] > 0) {
        event = [events firstObject];
    }
    
    if (completion) {
        completion(event, error);
    }
}

+ (void)fetchEventForYear:(NSUInteger)year fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *events, NSError *error))completion {
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
