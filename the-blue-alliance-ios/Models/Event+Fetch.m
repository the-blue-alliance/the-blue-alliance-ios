//
//  Event+Fetch.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/21/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Event+Fetch.h"

@implementation Event (Fetch)

+ (NSArray *)fetchEventsForYear:(NSUInteger)year fromContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@", @(year)];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error fetching events: %@", error.localizedDescription);
        return nil;
    }
    return events;
}

@end
