//
//  Team+Fetch.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Team+Fetch.h"
#import "Event.h"

@implementation Team (Fetch)

# pragma mark - Upstream

+ (NSUInteger)fetchAllTeamsWithTaskIdChange:(void (^_Nullable)(NSUInteger newTaskId, NSArray *_Nonnull batchTeam))taskIdChanged withCompletionBlock:(void(^_Nullable)(NSArray *_Nonnull teams, NSInteger totalCount, NSError *_Nullable error))completion {
    return [self fetchAllTeamsWithTaskIdChange:taskIdChanged withExistingTeams:nil forPage:0 withCompletionBlock:completion];
}

+ (NSUInteger)fetchAllTeamsWithTaskIdChange:(void (^)(NSUInteger newTaskId, NSArray *batchTeams))taskIdChanged withExistingTeams:(NSArray *)existingTeams forPage:(NSInteger)page withCompletionBlock:(void(^)(NSArray *teams, NSInteger totalCount, NSError *error))completion {
    __block NSArray *existingTeamsBlock = existingTeams;

    return [[TBAKit sharedKit] fetchTeamsForPage:page withCompletionBlock:^(NSArray *teams, NSInteger totalCount, NSError *error) {
        if (error) {
            completion(teams, totalCount, error);
            return;
        }
        
        if (!existingTeamsBlock) {
            existingTeamsBlock = [NSArray arrayWithArray:teams];
        } else {
            existingTeamsBlock = [existingTeamsBlock arrayByAddingObjectsFromArray:teams];
        }
        
        if ([teams count] == 0) {
            if (completion) {
                completion(existingTeamsBlock, [existingTeamsBlock count], error);
            }
        } else {
            NSUInteger newTaskId = [self fetchAllTeamsWithTaskIdChange:taskIdChanged withExistingTeams:existingTeamsBlock forPage:page + 1 withCompletionBlock:completion];
            if (taskIdChanged) {
                taskIdChanged(newTaskId, teams);
            }
        }
    }];
}


#pragma mark - Local

+ (void)fetchTeamForKey:(nonnull NSString *)key fromContext:(nonnull NSManagedObjectContext *)context checkUpstream:(BOOL)upstream withCompletionBlock:(void(^_Nullable)(Team *_Nullable team, NSError *_Nullable error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", key];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *teams = [context executeFetchRequest:fetchRequest error:&error];
    
    Team *team;
    if (teams && [teams count] > 0) {
        team = [teams firstObject];
    }
    
    if (team) {
        if (completion) {
            completion(team, error);
        }
    } else if (upstream) {
        [[TBAKit sharedKit] fetchTeamForTeamKey:key withCompletionBlock:^(TBATeam *upstreamTeam, NSError *error) {
            if (error || !upstreamTeam) {
                if (completion) {
                    completion(nil, error);
                }
            } else {
                Team *team = [Team insertTeamWithModelTeam:upstreamTeam inManagedObjectContext:context];
                if (completion) {
                    completion(team, nil);
                }
            }
        }];
    }
}

+ (void)fetchTeamsForKeys:(nonnull NSArray<NSString *> *)keys fromContext:(nonnull NSManagedObjectContext *)context withCompletionBlock:(void(^_Nullable)(NSArray *_Nullable teams, NSError *_Nullable error))completion {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key IN %@", keys];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *existingTeams = [context executeFetchRequest:fetchRequest error:&error];

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
    
    if (completion) {
        completion(teams, error);
    }
}

@end
