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

@end
