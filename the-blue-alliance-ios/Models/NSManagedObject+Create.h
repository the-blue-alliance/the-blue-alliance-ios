//
//  NSManagedObject+Create.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 6/28/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol NSManagedObjectCreatable <NSObject>

/** Subclasses of NSManagedObject need to implement this method such that they configure themselves for the given dictionary
 *
 * @param info A dictionary containing keys and values that specify properties for the object
 * @param context The NSManagedObjectContext for Core Data. Subclasses can use this context to do additional database fetches, for example to setup relationships.
 */
- (void)configureSelfForInfo:(NSDictionary *)info
   usingManagedObjectContext:(NSManagedObjectContext *)context;

@end




/** `NSManagedObject (Create)` is an abstraction for easier generation of managed objects.
 *   Each subclass of NSManagedObject which you intend to create using the below methods *must* conform to the NSManagedObjectCreatable protocol.
 */
@interface NSManagedObject (Create)

/** Creates and inserts an NSManagedObject into the database for a dictionary of information
 *
 * @param info A dictionary containing keys that specify properties for the object
 * @param context The context for Core Data
 * @return A managed object created with the given data
 */
+ (instancetype)createManagedObjectFromInfo:(NSDictionary *)info
      usingManagedObjectContext:(NSManagedObjectContext *)context;


/** Creates and inserts an array of NSManagedObject into the database for an array of dictionaries of information
 *
 * @param infoArray An array containing dictionaries containing keys that specify properties for the object
 * @param key A unique key which maps to both the dictionaries in infoArray and a property on the managed object, to check for pre-existance before inserting into database
 * @param context The context for Core Data
 * @return An managed object created with the given data
 */
+ (NSArray *)createManagedObjectsFromInfoArray:(NSArray *)infoArray
             checkingPrexistanceUsingUniqueKey:(NSString *)key
               usingManagedObjectContext:(NSManagedObjectContext *)context;

@end
