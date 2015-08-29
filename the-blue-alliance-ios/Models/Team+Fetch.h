//
//  Team+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "Team.h"
#import "TBAKit.h"

@interface Team (Fetch)

// Check upstream
+ (NSUInteger)fetchAllTeamsWithTaskIdChange:(void (^)(NSUInteger newTaskId, NSArray *batchTeam))taskIdChanged withCompletionBlock:(void(^)(NSArray *teams, NSInteger totalCount, NSError *error))completion;

// Check locally
+ (void)fetchTeamForKey:(NSString *)key fromContext:(NSManagedObjectContext *)context checkUpstream:(BOOL)upstream withCompletionBlock:(void(^)(Team *team, NSError *error))completion;
+ (void)fetchTeamsForKeys:(NSArray *)keys fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *teams, NSError *error))completion;
+ (void)fetchTeamsForEvent:(Event *)event fromContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSArray *teams, NSError *error))completion;

@end
