//
//  TBAApp.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/15/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TBAApp : NSObject

+ (NSManagedObjectContext *)managedObjectContext;
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

+ (void)saveContext;
+ (NSURL *)applicationDocumentsDirectory;

@end
