//
//  Team+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Team.h"

@interface Team (Fetch)

+ (NSArray *)fetchAllTeamsFromContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchTeamsWithPredicate:(NSPredicate *)predicate fromContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchTeamsForKeys:(NSArray *)keys fromContext:(NSManagedObjectContext *)context;

@end
