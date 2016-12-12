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
+ (NSUInteger)fetchAllTeamsWithTaskIdChange:(void (^_Nullable)(NSUInteger newTaskId, NSArray *_Nonnull batchTeam))taskIdChanged withCompletionBlock:(void(^_Nullable)(NSArray *_Nonnull teams, NSError *_Nullable error))completion;

@end
