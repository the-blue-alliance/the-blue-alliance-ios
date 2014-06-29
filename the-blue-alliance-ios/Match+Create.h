//
//  Match+Create.h
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "Match.h"

/** `Match+Create` encapsulates all creation of Match Core Data entities
 *  from TBA API results
 */
@interface Match (Create)

/** Create an Match object from a dictionary of information
 *
 * @param info A dictionary containing keys that match properities
 *  for a match object, and values for the object
 * @param context The context for Core Datas
 * @return A Match object with the data from info
 */
+ (Match *)createMatchFromTBAInfo:(NSDictionary *)info
         usingManagedObjectContext:(NSManagedObjectContext *)context;

/** Create Match objects from an array of match information
 *
 * @param infoArray An array containing sets of keys that match properities
 *  for a match object, and values for the object
 * @param context The context for Core Data
 * @param The matches which were either fetched or created
 */
+ (NSSet *)createMatchesFromTBAInfoArray:(NSArray *)infoArray
            usingManagedObjectContext:(NSManagedObjectContext *)context;

@end
