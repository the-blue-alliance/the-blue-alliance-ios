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

+ (void)fetchEventsForYear:(NSUInteger)year fromContext:(nonnull NSManagedObjectContext *)context withCompletionBlock:(void(^_Nullable)(NSArray<Event *> *_Nullable events, NSError *_Nullable error))completion {
    NSFetchRequest *fetchRequest = [Event fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@", @(year)];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *startDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[startDateSortDescriptor, nameSortDescriptor]];
    
    NSError *error = nil;
    NSArray *events = [fetchRequest execute:&error];
    
    if (completion) {
        completion(events, error);
    }
}

@end
