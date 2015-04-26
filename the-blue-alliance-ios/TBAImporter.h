//
//  DatabaseImporter.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>


/** `TBAImporter` is a utility class used to encapsulate the various downloading
 * logic for importing data from TBA API.
 *
 * Just imports? No exports?
 * https://www.youtube.com/watch?v=67L0pbneT2w
 *
 */
@interface TBAImporter : NSObject

+ (NSArray *)importEvents:(NSArray *)events;
+ (NSArray *)importTeams:(NSArray *)teams;

/*
+ (void)importTeamsUsingManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)linkTeamsToEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)linkEventsToTeam:(Team *)team forYear:(NSInteger)year usingManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)linkMediaToTeam:(Team *)team forYear:(NSInteger)year usingManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)importRankingsForEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context callback:(void (^)(NSString *rankingsString))callback;
+ (void)importMatchesForEvent:(Event *)event usingManagedObjectContext:(NSManagedObjectContext *)context callback:(void (^)(NSSet *matches))callback;
*/
 
@end
