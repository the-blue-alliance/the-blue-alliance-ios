//
//  Team+Create.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Team.h"

/** `Event+Create` encapsulates all creation of Team Core Data entities
 *  from TBA API results
 */
@interface Team (Create)

/** Create a Team object from a dictionary of information
 *
 * @param info A dictionary containing keys that match properities
 *  for a team object, and values for the object
 * @param context The context for Core Datas
 * @return An Team object created and inserted into database from the dictionary
 */
+ (Team *)createTeamFromTBAInfo:(NSDictionary *)info
        usingManagedObjectContext:(NSManagedObjectContext *)context;

/** Creates and inserts Team entities into the database from an array of 
 *  dictionaries representing teams
 *
 * @param infoArray An array containing dictionaries containing keys that match properities
 *  for a team object, and values for the object
 * @param context The context for Core Datas
 */
+ (void)createTeamsFromTBAInfoArray:(NSArray *)infoArray
           usingManagedObjectContext:(NSManagedObjectContext *)context;

@end
