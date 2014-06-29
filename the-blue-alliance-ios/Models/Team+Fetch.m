//
//  Team+Fetch.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Team+Fetch.h"

@implementation Team (Fetch)

+ (NSArray *)fetchTeamsForKeys:(NSArray *)keys fromContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Team" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key IN %@", keys];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *existingTeams = [context executeFetchRequest:fetchRequest error:&error];
    if (existingTeams == nil) {
        NSLog(@"Core Data error: handle this error... :(");
        NSLog(@"%@", error);
    }
    
    
    // Put existingTeams into the order the keys were provided, and insert NSNull for a team that doesn't exist
    NSMutableArray *teams = [[NSMutableArray alloc] init];
    for (NSString *key in keys) {
        NSUInteger index = [existingTeams indexOfObjectPassingTest:^BOOL(Team *obj, NSUInteger idx, BOOL *stop) {
            return [obj.key isEqualToString:key];
        }];
        if(index == NSNotFound) {
            [teams addObject:[NSNull null]];
        } else {
            [teams addObject:existingTeams[index]];
        }
    }

    return teams;
}

@end
