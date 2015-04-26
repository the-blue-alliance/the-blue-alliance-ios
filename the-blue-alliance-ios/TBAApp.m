//
//  TBAApp.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/15/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAApp.h"

@implementation TBAApp

#pragma mark Singleton Helpers

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSManagedObjectModel *)managedObjectModel {
    static NSManagedObjectModel *managedObjectModel_;
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TBA" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel_;
}

+ (NSManagedObjectContext *)managedObjectContext {
    static NSManagedObjectContext *managedObjectContext_;
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    managedObjectContext_ = [[NSManagedObjectContext alloc] init];
    [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    return managedObjectContext_;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    static NSPersistentStoreCoordinator *persistentStoreCoordinator_;
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TBA.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return persistentStoreCoordinator_;
}


#pragma mark - Core Data Saving support

+ (void)saveContext {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
