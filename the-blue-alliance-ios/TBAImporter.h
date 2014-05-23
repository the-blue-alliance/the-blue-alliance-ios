//
//  DatabaseImporter.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/23/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBAImporter : NSObject

/** Downloads a list of all the events from TBA and saves to Core Data as necesasry
 * 
 * @param context The context of the database used for importing
 */
+ (void) importEventsUsingManagedObjectContext:(NSManagedObjectContext *)context;

@end
