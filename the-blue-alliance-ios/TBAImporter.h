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
 */
@interface TBAImporter : NSObject

/** Downloads a list of all the events from TBA and saves to Core Data as necesasry
 * 
 * @param context The context of the database used for importing
 */
+ (void) importEventsUsingManagedObjectContext:(NSManagedObjectContext *)context;

/** Downloads a list of all the teams from TBA and saves to Core Data as necesasry
 *
 * @param context The context of the database used for importing
 */
+ (void) importTeamsUsingManagedObjectContext:(NSManagedObjectContext *)context;

@end
