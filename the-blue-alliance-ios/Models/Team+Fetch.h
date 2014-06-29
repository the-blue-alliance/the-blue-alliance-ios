//
//  Team+Fetch.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Team.h"

@interface Team (Fetch)

/** Fetches Teams from Core Data based on an array of given keys
 *
 * @param keys An array of team keys for teams you want to fetch
 * @param context The context for Core Data
 * @return An array of Team objects, guarenteed to be in the same order as the given keys.
 * if a team can not be fetched, then [NSNull null] is inserted.
 */
+ (NSArray *)fetchTeamsForKeys:(NSArray *)keys fromContext:(NSManagedObjectContext *)context;

@end
