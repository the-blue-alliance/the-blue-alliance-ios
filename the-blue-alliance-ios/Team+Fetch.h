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
+ (NSUInteger)fetchAllTeamsWithTaskIdChange:(void (^_Nullable)(NSUInteger newTaskId, NSArray *_Nonnull batchTeam))taskIdChanged withCompletionBlock:(void(^_Nullable)(NSArray *_Nonnull teams, NSInteger totalCount, NSError *_Nullable error))completion;

// Check locally
+ (void)fetchTeamForKey:(nonnull NSString *)key fromContext:(nonnull NSManagedObjectContext *)context checkUpstream:(BOOL)upstream withCompletionBlock:(void(^_Nullable)(Team *_Nullable team, NSError *_Nullable error))completion;
+ (void)fetchTeamsForKeys:(nonnull NSArray<NSString *> *)keys fromContext:(nonnull NSManagedObjectContext *)context withCompletionBlock:(void(^_Nullable)(NSArray *_Nullable teams, NSError *_Nullable error))completion;

@end
